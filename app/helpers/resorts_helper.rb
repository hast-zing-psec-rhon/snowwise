module ResortsHelper
  HERO_NAV_LINKS = ["Conditions", "Map"].freeze

  def hero_nav_links
    HERO_NAV_LINKS
  end

  def resort_location_text(resort)
    [resort.city, resort.state_or_region, resort.country]
      .compact_blank
      .join(", ")
  end

  def current_forecast_for(resort)
    resort.primary_location&.weather_forecasts&.find do |forecast|
      forecast.forecast_type == "current"
    end
  end

  def daily_forecasts_for(resort)
    resort.primary_location&.weather_forecasts
      &.select { |forecast| forecast.forecast_type == "daily" }
      &.sort_by(&:forecast_for)
      &.first(7) || []
  end

  def weather_summary(forecast)
    return "Forecast pending" if forecast.blank?

    precip_probability = forecast.precip_probability.to_f

    if snow_forecast?(forecast)
      "Snow"
    elsif forecast.precip_type == "rain" && precip_probability >= 0.35
      "Rain"
    elsif precip_probability >= 0.35
      "Mixed precip"
    elsif forecast.cloud_cover.to_f >= 0.65
      "Cloudy"
    elsif forecast.cloud_cover.to_f >= 0.35
      "Partly cloudy"
    else
      "Clear"
    end
  end

  def weather_icon_name(forecast)
    return "cloudy" if forecast.blank?
    return "snow" if snow_forecast?(forecast)
    return "rain" if forecast.precip_type == "rain" && forecast.precip_probability.to_f >= 0.35

    summary = weather_summary(forecast)

    case summary
    when "Cloudy"
      "cloudy"
    when "Partly cloudy"
      "partly_cloudy"
    else
      "clear"
    end
  end

  def snow_forecast?(forecast)
    return false if forecast.blank? || forecast.precip_type != "snow"

    forecast.precip_probability.to_f >= 0.35 || forecast_snow_amount(forecast).positive?
  end

  def forecast_snow_amount(forecast)
    return 0.0 if forecast.blank? || forecast.precip_type != "snow"

    (forecast.raw_data["snowAccumulation"] || forecast.raw_data["precipAccumulation"]).to_f
  end



  def formatted_temperature(value)
    return "--" if value.blank?

    "#{value.round}°F"
  end

  def formatted_wind_speed(forecast)
    return "--" if forecast&.wind_speed.blank?

    "#{forecast.wind_speed.round(1)} mph"
  end

  def formatted_precip_probability(forecast)
    return "--" if forecast&.precip_probability.blank?

    number_to_percentage(forecast.precip_probability * 100, precision: 0)
  end

  def snow_depth_label(resort)
    observation = resort.latest_snow_observation
    return "--" if observation&.base_depth_inches.blank?

    "#{observation.base_depth_inches.round}\""
  end

  def daily_snow_label(forecast)
    snow_amount = forecast_snow_amount(forecast)
    return "--" unless snow_amount.positive?

    "#{snow_amount.round(1)}\""
  end

  def condition_score_for(resort, current_forecast)
    condition_score_result_for(resort, current_forecast).score
  end

  def condition_score_label(_score, resort = nil)
    return "N/A" if resort.blank?

    condition_score_result_for(resort, current_forecast_for(resort)).label
  end

  def condition_score_result_for(resort, current_forecast)
    Conditions::ScoreCalculator.call(
      resort: resort,
      snow_observation: resort.latest_snow_observation,
      weather_forecast: current_forecast,
      daily_forecasts: daily_forecasts_for(resort)
    )
  end

  def condition_score_ring_class(score)
    return "score-ring-unavailable" if score.blank?
    return "score-ring-poor" if score < 45
    return "score-ring-fair" if score < 65

    "score-ring-good"
  end

  def condition_score_ring_style(score)
    fill_percentage = score.present? ? score.to_i.clamp(0, 100) : 0

    "--score-fill: #{fill_percentage}%"
  end

  def pass_badge_class(pass_name)
    case pass_name
    when "Ikon Pass"
      "pass-chip pass-chip-ikon"
    when "Epic Pass"
      "pass-chip pass-chip-epic"
    else
      "pass-chip pass-chip-muted"
    end
  end

  def resort_pass_accesses(resort)
    resort.pass_accesses.sort_by { |access| access.pass_product.name }
  end

  def resort_image_class(resort)
    classes = [resort_photo_class(resort)]
    classes << "resort-photo-with-image" if resort.image_url.present?
    classes << "resort-photo-#{resort.image_type}" if resort.image_type.present?
    classes.join(" ")
  end

  def resort_image_alt(resort)
    resort.image_type == "logo" ? "#{resort.name} logo" : "#{resort.name} mountain image"
  end

  def resort_photo_class(resort)
    region_class = {
      "Andorra" => "europe",
      "Austria" => "europe",
      "France" => "europe",
      "Italy" => "europe",
      "Switzerland" => "europe",
      "Canada" => "north-america",
      "United States" => "north-america",
      "Chile" => "south-america",
      "China" => "asia",
      "Japan" => "asia",
      "South Korea" => "asia",
      "Australia" => "oceania",
      "New Zealand" => "oceania"
    }.fetch(resort.country, "north-america")

    "resort-photo resort-photo-#{region_class}"
  end
end
