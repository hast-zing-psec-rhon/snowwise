require "rails_helper"

RSpec.describe Conditions::RefreshScore do
  let(:as_of) { Time.zone.local(2026, 4, 10, 12, 0, 0) }
  let(:resort) do
    Resort.create!(
      name: "Example Mountain",
      country: "United States",
      state_or_region: "Colorado"
    )
  end
  let!(:location) do
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
  let!(:snow_observation) do
    SnowObservation.create!(
      resort: resort,
      snow_report_source: source,
      queried_at: as_of,
      observed_at: as_of - 2.hours,
      base_depth_inches: 36,
      upper_depth_inches: 60,
      new_snow_24h_inches: 4,
      new_snow_48h_inches: 8,
      new_snow_7d_inches: 18,
      operating_status: "open",
      source_url: "https://example.com/snow",
      source_name: "Official snow report",
      extraction_method: "manual_seed",
      confidence: "high"
    )
  end
  let!(:weather_forecast) do
    WeatherForecast.create!(
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
    )
  end

  it "saves the current condition score for a resort" do
    score_record = described_class.call(resort: resort, as_of: as_of)

    expect(score_record).to be_persisted
    expect(score_record.resort).to eq(resort)
    expect(score_record.snow_observation).to eq(snow_observation)
    expect(score_record.weather_forecast).to eq(weather_forecast)
    expect(score_record.score).to be_between(0, 100)
    expect(score_record.label).to be_present
    expect(score_record.calculated_at).to eq(as_of)
  end

  it "updates the existing score instead of creating duplicates" do
    described_class.call(resort: resort, as_of: as_of)

    expect {
      described_class.call(resort: resort, as_of: as_of + 1.hour)
    }.not_to change(ResortConditionScore, :count)

    expect(resort.reload.resort_condition_score.calculated_at).to eq(as_of + 1.hour)
  end
end
