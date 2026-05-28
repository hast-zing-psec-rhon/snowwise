require "rails_helper"

RSpec.describe Conditions::ScoreCalculator do
  let(:as_of) { Time.zone.local(2026, 4, 10, 12, 0, 0) }
  let(:resort) do
    Resort.create!(
      name: "Example Mountain",
      country: "United States",
      state_or_region: "Colorado"
    )
  end
  let(:location) do
    ResortLocation.create!(
      resort: resort,
      name: "Primary Base",
      location_type: "base",
      latitude: 39.64,
      longitude: -106.37,
      is_primary: true
    )
  end
  let(:source) do
    SnowReportSource.create!(
      resort: resort,
      provider_name: "Official",
      source_name: "Official snow report",
      source_url: "https://example.com/snow",
      source_type: "official_resort"
    )
  end

  def snow_observation(attributes = {})
    SnowObservation.create!(
      {
        resort: resort,
        snow_report_source: source,
        queried_at: as_of,
        observed_at: as_of - 2.hours,
        base_depth_inches: 36,
        new_snow_24h_inches: 4,
        new_snow_48h_inches: 8,
        new_snow_7d_inches: 18,
        operating_status: "open",
        source_url: "https://example.com/snow",
        source_name: "Official snow report",
        extraction_method: "manual_seed",
        confidence: "high"
      }.merge(attributes)
    )
  end

  def weather_forecast(attributes = {})
    WeatherForecast.create!(
      {
        resort_location: location,
        provider: "pirate_weather",
        forecast_type: "current",
        forecast_for: as_of,
        fetched_at: as_of,
        temperature: 27,
        temperature_high: 31,
        temperature_low: 18,
        wind_speed: 8,
        precip_type: "snow",
        precip_probability: 0.35,
        raw_data: {}
      }.merge(attributes)
    )
  end

  def calculate(snow:, weather:)
    described_class.call(
      resort: resort,
      snow_observation: snow,
      weather_forecast: weather,
      as_of: as_of
    )
  end

  it "returns N/A when the resort is out of ski operations" do
    result = calculate(
      snow: snow_observation(operating_status: "offseason"),
      weather: weather_forecast
    )

    expect(result.score).to be_nil
    expect(result.label).to eq("N/A")
    expect(result.reasons).to include(:closed)
  end

  it "returns N/A when there is weather but no usable snow signal" do
  result = calculate(
    snow: nil,
    weather: weather_forecast(
      temperature: 28,
      wind_speed: 6,
      precip_type: nil,
      precip_probability: 0
    )
  )

  expect(result.score).to be_nil
  expect(result.label).to eq("N/A")
  expect(result.data_quality).to eq("unavailable")
  expect(result.reasons).to include(:insufficient_data)
end

it "scores a strong powder day highly" do
    result = calculate(
      snow: snow_observation(
        upper_depth_inches: 72,
        new_snow_24h_inches: 14,
        new_snow_48h_inches: 20,
        new_snow_7d_inches: 36
      ),
      weather: weather_forecast(
        temperature: 24,
        wind_speed: 12,
        precip_type: "snow",
        precip_probability: 0.40
      )
    )

    expect(result.score).to be_between(90, 100)
    expect(result.label).to eq("Excellent")
    expect(result.reasons).to include(:strong_base, :recent_snow)
  end

  it "caps warm spring days with a low base" do
    result = calculate(
      snow: snow_observation(
        base_depth_inches: 14,
        upper_depth_inches: nil,
        new_snow_24h_inches: 0,
        new_snow_48h_inches: 0,
        new_snow_7d_inches: 2
      ),
      weather: weather_forecast(
        temperature: 39,
        temperature_high: 48,
        wind_speed: 8,
        precip_type: nil,
        precip_probability: 0
      )
    )

    expect(result.score).to be_between(25, 55)
    expect(result.label).to match(/Poor|Fair/)
    expect(result.reasons).to include(:thin_base, :warm_spring_weather)
  end

  it "still scores partial data, but caps the score when snow depth is missing" do
    result = calculate(
      snow: snow_observation(
        base_depth_inches: nil,
        mid_depth_inches: nil,
        upper_depth_inches: nil,
        new_snow_24h_inches: 6,
        new_snow_48h_inches: 8,
        new_snow_7d_inches: nil
      ),
      weather: weather_forecast(
        temperature: 27,
        wind_speed: 10,
        precip_type: "snow",
        precip_probability: 0.30
      )
    )

    expect(result.score).to be_between(45, 75)
    expect(result.score).to be <= 75
    expect(result.label).not_to eq("N/A")
    expect(result.reasons).to include(:missing_snow_depth, :missing_data)
  end

  it "heavily penalizes rain and high wind even with a deep base" do
    result = calculate(
      snow: snow_observation(
        upper_depth_inches: 70,
        new_snow_24h_inches: 4,
        new_snow_48h_inches: 8,
        new_snow_7d_inches: 18
      ),
      weather: weather_forecast(
        temperature: 39,
        temperature_high: 44,
        wind_speed: 42,
        precip_type: "rain",
        precip_probability: 0.80
      )
    )

    expect(result.score).to be <= 40
    expect(result.label).to eq("Poor")
    expect(result.reasons).to include(:rain_penalty, :high_wind)
  end
end
