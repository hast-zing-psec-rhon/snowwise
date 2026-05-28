module Conditions
  class RefreshScore
    def self.call(resort:, as_of: Time.current)
      new(resort: resort, as_of: as_of).call
    end

    def initialize(resort:, as_of:)
      @resort = resort
      @as_of = as_of
    end

    def call
      result = ScoreCalculator.call(
        resort: resort,
        snow_observation: snow_observation,
        weather_forecast: current_forecast,
        daily_forecasts: daily_forecasts,
        as_of: as_of
      )

      score_record = ResortConditionScore.find_or_initialize_by(resort: resort)
      score_record.update!(
        snow_observation: snow_observation,
        weather_forecast: current_forecast,
        score: result.score,
        label: result.label,
        data_quality: result.data_quality,
        reasons: result.reasons.map(&:to_s),
        calculated_at: as_of
      )
      score_record
    end

    private

    attr_reader :resort, :as_of

    def snow_observation
      @snow_observation ||= resort.latest_snow_observation
    end

    def current_forecast
      @current_forecast ||= resort.primary_location&.weather_forecasts&.find do |forecast|
        forecast.forecast_type == "current"
      end
    end

    def daily_forecasts
      @daily_forecasts ||= resort.primary_location&.weather_forecasts
        &.select { |forecast| forecast.forecast_type == "daily" }
        &.sort_by(&:forecast_for)
        &.first(7) || []
    end
  end
end
