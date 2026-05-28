module Conditions
  class ScoreCalculator
    Result = Struct.new(:score, :label, :reasons, :data_quality, keyword_init: true)

    CLOSED_STATUSES = %w[
      closed
      offseason
      pre-season
      preseason
      summer
      summer_operations
      temporarily_closed
    ].freeze

    def self.call(resort:, snow_observation:, weather_forecast:, daily_forecasts: [], as_of: Time.current)
      new(
        resort: resort,
        snow_observation: snow_observation,
        weather_forecast: weather_forecast,
        daily_forecasts: daily_forecasts,
        as_of: as_of
      ).call
    end

    def initialize(resort:, snow_observation:, weather_forecast:, daily_forecasts:, as_of:)
      @resort = resort
      @snow_observation = snow_observation
      @weather_forecast = weather_forecast
      @daily_forecasts = daily_forecasts
      @as_of = as_of
      @reasons = []
      @max_score = 100
    end

    def call
      return result(nil, "N/A", :closed) if closed?
      return result(nil, "N/A", :insufficient_data) unless enough_data_to_score?

      raw_score =
        (35 * base_depth_component) +
        (25 * recent_snow_component) +
        (10 * forecast_snow_component) +
        (15 * temperature_component) +
        (10 * wind_component) +
        (5 * data_freshness_component)

      score = raw_score - rain_penalty - missing_data_penalty
      score = [score, max_score].min
      score = score.round.clamp(0, 100)

      result(score, label_for(score))
    end

    private

    attr_reader :resort, :snow_observation, :weather_forecast, :daily_forecasts, :as_of, :reasons
    attr_accessor :max_score

    def result(score, label, reason = nil)
      reasons << reason if reason.present?

      Result.new(
        score: score,
        label: label,
        reasons: reasons.uniq,
        data_quality: data_quality
      )
    end

    def closed?
      CLOSED_STATUSES.include?(snow_observation&.operating_status.to_s)
    end

    def enough_data_to_score?
      snow_signal? && weather_signal?
    end

    def snow_signal?
      snow_depth.present? || recent_snow_values.any?(&:present?)
    end

    def weather_signal?
      temperature.present? ||
        weather_forecast&.wind_speed.present? ||
        weather_forecast&.precip_type.present? ||
        weather_forecast&.precip_probability.present?
    end

    def base_depth_component
      depth = snow_depth

      unless depth.present?
        self.max_score = [max_score, 75].min
        reasons << :missing_snow_depth
        return recent_snow_values.any?(&:present?) ? 0.20 : 0.0
      end

      baseline = baseline_for_score
      good_depth = baseline.good_base_depth_inches
      baseline_depth = baseline.baseline_base_depth_inches
      excellent_depth = baseline.excellent_base_depth_inches

      component = clamp(depth / good_depth)
      component = 1.0 if depth >= excellent_depth

      if depth < baseline_depth
        component *= clamp(depth / baseline_depth)
        reasons << :thin_base
      elsif depth >= good_depth
        reasons << :strong_base
      end

      if depth < 8
        self.max_score = [max_score, 35].min
      elsif depth < 16
        self.max_score = [max_score, 55].min
      elsif spring_month? && depth < baseline_depth
        self.max_score = [max_score, 60].min
      end

      component * confidence_multiplier
    end

    def recent_snow_component
      snow_24h = snow_observation&.new_snow_24h_inches.to_f
      snow_48h = snow_observation&.new_snow_48h_inches.to_f
      snow_7d = snow_observation&.new_snow_7d_inches.to_f

      unless recent_snow_values.any?(&:present?)
        reasons << :missing_recent_snow
        return 0.0
      end

      component =
        (0.60 * clamp(snow_24h / 10.0)) +
        (0.25 * clamp(snow_48h / 18.0)) +
        (0.15 * clamp(snow_7d / 36.0))

      if temperature.present? && precip_type != "snow"
        component *= 0.75 if temperature > 34
        component *= 0.50 if temperature > 40
      end

      component *= 0.25 if precip_type == "rain"
      reasons << :recent_snow if component >= 0.35

      clamp(component) * confidence_multiplier
    end

    def forecast_snow_component
      probability = weather_forecast&.precip_probability.to_f

      case precip_type
      when "snow"
        reasons << :snow_forecast if probability >= 0.35
        clamp(probability)
      when "sleet", "mixed", "wintry_mix"
        0.30 * clamp(probability)
      else
        0.0
      end
    end

    def temperature_component
      temp = temperature

      unless temp.present?
        reasons << :missing_temperature
        return 0.0
      end

      component =
        case temp
        when -10..28 then 1.00
        when 29..32 then 0.95
        when 33..36 then 0.80
        when 37..40 then 0.55
        when 41..45 then 0.30
        else 0.10
        end

      if spring_month? && weather_forecast&.temperature_high.present? && weather_forecast.temperature_high > 42
        component = [component, 0.45].min
        reasons << :warm_spring_weather
      elsif temp > 40
        reasons << :warm_weather
      elsif temp <= 32
        reasons << :cold_snow_preservation
      end

      component
    end

    def wind_component
      wind_speed = weather_forecast&.wind_speed

      unless wind_speed.present?
        reasons << :missing_wind
        return 0.0
      end

      case wind_speed
      when 0...15
        1.00
      when 15...25
        0.80
      when 25...35
        reasons << :windy
        0.50
      when 35...45
        reasons << :high_wind
        0.25
      else
        reasons << :high_wind
        0.05
      end
    end

    def rain_penalty
      probability = weather_forecast&.precip_probability.to_f

      case precip_type
      when "rain"
        reasons << :rain_penalty if probability.positive?
        self.max_score = [max_score, 45].min if probability >= 0.60
        self.max_score = [max_score, 40].min if temperature.present? && temperature > 38

        (30 * probability) +
          (temperature.present? && temperature > 34 ? 10 : 0) +
          (weather_forecast&.temperature_high.present? && weather_forecast.temperature_high > 40 ? 10 : 0)
      when "mixed", "sleet"
        reasons << :mixed_precipitation if probability.positive?
        12 * probability
      else
        0
      end
    end

    def data_freshness_component
      return 0.0 if snow_observation.blank?

      observed_time = snow_observation.observed_at || snow_observation.queried_at
      return 0.0 if observed_time.blank?

      age_hours = (as_of - observed_time) / 1.hour

      case age_hours
      when 0..12
        1.00
      when 12..24
        0.80
      when 24..48
        reasons << :stale_snow_observation
        0.50
      when 48..72
        reasons << :stale_snow_observation
        0.25
      else
        reasons << :stale_snow_observation
        0.00
      end
    end

    def missing_data_penalty
      penalty = 0

      unless snow_depth.present?
        penalty += recent_snow_values.any?(&:present?) ? 6 : 12
        self.max_score = [max_score, 75].min
      end

      penalty += 6 unless recent_snow_values.any?(&:present?)
      penalty += 6 unless temperature.present?
      penalty += 4 unless weather_forecast&.wind_speed.present?
      penalty += 4 unless weather_forecast&.precip_type.present? || weather_forecast&.precip_probability.present?

      if snow_observation.blank?
        self.max_score = [max_score, 65].min
      elsif snow_observation_stale?
        penalty += 6
      end

      reasons << :missing_data if penalty.positive?
      penalty
    end

    def data_quality
      return "unavailable" unless enough_data_to_score?
      return "limited" if reasons.include?(:missing_data) || reasons.include?(:stale_snow_observation)

      "good"
    end

    def label_for(score)
      return "Excellent" if score >= 90
      return "Very Good" if score >= 80
      return "Good" if score >= 65
      return "Fair" if score >= 45

      "Poor"
    end

    def baseline_for_score
      @baseline_for_score ||= BaselineLookup.call(
        resort: resort,
        month: score_month
      )
    end

    def score_month
      (weather_forecast&.forecast_for || snow_observation&.observed_at || snow_observation&.queried_at || as_of).month
    end

    def spring_month?
      [3, 4, 5].include?(score_month)
    end

    def snow_depth
      @snow_depth ||= [
        snow_observation&.upper_depth_inches,
        snow_observation&.mid_depth_inches,
        snow_observation&.base_depth_inches
      ].compact.max
    end

    def recent_snow_values
      [
        snow_observation&.new_snow_24h_inches,
        snow_observation&.new_snow_48h_inches,
        snow_observation&.new_snow_7d_inches
      ]
    end

    def temperature
      return weather_forecast.temperature if weather_forecast&.temperature.present?

      if weather_forecast&.temperature_high.present? && weather_forecast&.temperature_low.present?
        (weather_forecast.temperature_high + weather_forecast.temperature_low) / 2.0
      end
    end

    def precip_type
      weather_forecast&.precip_type.to_s
    end

    def confidence_multiplier
      case snow_observation&.confidence
      when "high" then 1.0
      when "medium" then 0.85
      when "low" then 0.65
      else 1.0
      end
    end

    def snow_observation_stale?
      return false if snow_observation.blank?

      observed_time = snow_observation.observed_at || snow_observation.queried_at
      observed_time.present? && observed_time < as_of - 72.hours
    end

    def clamp(value)
      value.to_f.clamp(0.0, 1.0)
    end
  end
end
