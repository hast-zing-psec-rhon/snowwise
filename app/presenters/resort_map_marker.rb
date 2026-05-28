class ResortMapMarker
  REGION_BY_COUNTRY = ResortsController::REGION_BY_COUNTRY
  SOUTHERN_HEMISPHERE_COUNTRIES = ["Australia", "Chile", "New Zealand"].freeze

  def initialize(resort)
    @resort = resort
  end

  def as_json(*)
    {
      id: resort.id,
      name: resort.name,
      location: location_label,
      region: region,
      latitude: latitude,
      longitude: longitude,
      pass_type: pass_type,
      pass_types: pass_types,
      current_temperature: current_temperature,
      weather_summary: weather_summary,
      weather_icon_key: weather_icon_key,
      wind_mph: wind_mph,
      precip_probability: precip_probability,
      snow_depth_inches: snow_depth_inches,
      new_snow_24h_inches: new_snow_24h_inches,
      forecast_snow_7d_inches: forecast_snow_7d_inches,
      forecast_snow_expected: forecast_snow_expected?,
      conditions_score: conditions_score,
      condition_label: score_result.label,
      condition_quality: condition_quality,
      open_status: open_status,
      detail_url: resort.website_url.presence || "#",
      updated_label: updated_label
    }
  end

  private

  attr_reader :resort

  def current_forecast
    @current_forecast ||= weather_forecasts.find { |forecast| forecast.forecast_type == "current" }
  end

  def daily_forecasts
    @daily_forecasts ||= weather_forecasts
      .select { |forecast| forecast.forecast_type == "daily" }
      .sort_by(&:forecast_for)
      .first(7)
  end

  def weather_forecasts
    resort.primary_location&.weather_forecasts || []
  end

  def snow_observation
    resort.latest_snow_observation
  end

  def score_result
    @score_result ||= Conditions::ScoreCalculator.call(
      resort: resort,
      snow_observation: snow_observation,
      weather_forecast: current_forecast,
      daily_forecasts: daily_forecasts
    )
  end

  def location_label
    [resort.city, resort.state_or_region, resort.country].compact_blank.join(", ")
  end

  def region
    REGION_BY_COUNTRY.fetch(resort.country, "Other")
  end

  def latitude
    (resort.primary_location&.latitude || resort.latitude).to_f
  end

  def longitude
    (resort.primary_location&.longitude || resort.longitude).to_f
  end

  def pass_types
    @pass_types ||= resort.pass_accesses.map { |access| normalized_pass_name(access.pass_product.name) }.uniq
  end

  def pass_type
    return "Ikon + Epic" if pass_types.include?("Ikon") && pass_types.include?("Epic")
    return pass_types.first if pass_types.any?

    "No Pass"
  end

  def normalized_pass_name(name)
    case name.to_s
    when /ikon/i then "Ikon"
    when /epic/i then "Epic"
    else name.to_s.presence || "No Pass"
    end
  end

  def current_temperature
    current_forecast&.temperature&.round || current_forecast&.temperature_high&.round || 0
  end

  def weather_summary
    return "Snow" if current_forecast&.precip_type == "snow" && current_forecast.precip_probability.to_f >= 0.35
    return "Rain" if current_forecast&.precip_type == "rain" && current_forecast.precip_probability.to_f >= 0.35
    return snow_observation.surface_condition if snow_observation&.surface_condition.present?

    current_forecast.present? ? "Current forecast" : "Forecast pending"
  end

  def weather_icon_key
    return "snow" if current_forecast&.precip_type == "snow"
    return "rain" if current_forecast&.precip_type == "rain"
    return "cloudy" if current_forecast&.cloud_cover.to_f >= 0.65
    return "partly_cloudy" if current_forecast&.cloud_cover.to_f >= 0.35

    "clear"
  end

  def wind_mph
    current_forecast&.wind_speed&.round(1) || 0
  end

  def precip_probability
    (current_forecast&.precip_probability.to_f * 100).round
  end

  def snow_depth_inches
    [
      snow_observation&.upper_depth_inches,
      snow_observation&.mid_depth_inches,
      snow_observation&.base_depth_inches
    ].compact.max&.round || 0
  end

  def new_snow_24h_inches
    snow_observation&.new_snow_24h_inches&.round(1) || 0
  end

  def forecast_snow_7d_inches
    snow_observation&.new_snow_7d_inches&.round(1) || daily_snow_total
  end

  def forecast_snow_expected?
    daily_forecasts.any? do |forecast|
      forecast.precip_type == "snow" && forecast_snow_amount(forecast).positive?
    end
  end

  def daily_snow_total
    daily_forecasts.sum { |forecast| forecast_snow_amount(forecast) }.round(1)
  end

  def forecast_snow_amount(forecast)
    return 0.0 unless forecast.precip_type == "snow"

    (forecast.raw_data["snowAccumulation"] || forecast.raw_data["precipAccumulation"]).to_f
  end

  def conditions_score
    score_result.score
  end

  def condition_quality
    return "unavailable" if score_result.score.blank?
    return "poor" if score_result.score < 45
    return "fair" if score_result.score < 65

    "good"
  end

  def open_status
    status = snow_observation&.operating_status.to_s
    return "closed" if Conditions::ScoreCalculator::CLOSED_STATUSES.include?(status)
    return "open" if status == "open"
    return "closed" if closed_status_text?
    return "open" if open_status_text?

    seasonal_open_status
  end

  def seasonal_open_status
    month = Time.zone.today.month

    if SOUTHERN_HEMISPHERE_COUNTRIES.include?(resort.country)
      [6, 7, 8, 9].include?(month) ? "unknown" : "closed"
    else
      [12, 1, 2, 3].include?(month) ? "unknown" : "closed"
    end
  end

  def closed_status_text?
    status_text.match?(
      /\b(closed|off[- ]?season|end[- ]?of[- ]?season|season (?:has )?concluded|pre[- ]?season|summer operations?|0 trails open|no trails open|final winter report)\b/i
    )
  end

  def open_status_text?
    status_text.match?(/\b(open|planned open|operating|lifts? open|trails? open)\b/i)
  end

  def status_text
    [
      snow_observation&.surface_condition,
      snow_observation&.notes,
      snow_observation&.source_name,
      snow_observation&.zero_depth_reason
    ].compact.join(" ")
  end

  def updated_label
    timestamp = snow_observation&.observed_at || snow_observation&.queried_at || current_forecast&.fetched_at
    return "Updated recently" if timestamp.blank?

    "Updated #{timestamp.to_date.to_fs(:long)}"
  end
end
