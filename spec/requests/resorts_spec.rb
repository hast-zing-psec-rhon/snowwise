require "rails_helper"

RSpec.describe "Resorts", type: :request do
  let(:as_of) { Time.zone.local(2026, 1, 10, 12, 0, 0) }
  let!(:ikon) { PassProduct.create!(name: "Ikon Pass", season: "2026-2027") }
  let!(:epic) { PassProduct.create!(name: "Epic Pass", season: "2026-2027") }
  let!(:source) do
    SnowReportSource.create!(
      resort: mammoth,
      provider_name: "Official",
      source_name: "Official snow report",
      source_url: "https://example.com/mammoth/snow",
      source_type: "official_resort"
    )
  end
  let!(:mammoth) do
    Resort.create!(
      name: "Mammoth Mountain",
      city: "Mammoth Lakes",
      state_or_region: "California",
      country: "United States"
    )
  end
  let!(:whistler) do
    Resort.create!(
      name: "Whistler Blackcomb",
      city: "Whistler",
      state_or_region: "British Columbia",
      country: "Canada"
    )
  end
  let!(:niseko) do
    Resort.create!(
      name: "Niseko United",
      city: "Niseko",
      state_or_region: "Hokkaido",
      country: "Japan"
    )
  end

  before do
    create_location_with_weather(mammoth, temperature: 18)
    create_location_with_weather(whistler, temperature: 29)
    create_location_with_weather(niseko, temperature: 36)

    SnowObservation.create!(
      resort: mammoth,
      snow_report_source: source,
      queried_at: as_of,
      observed_at: as_of,
      base_depth_inches: 40,
      new_snow_24h_inches: 8,
      source_url: "https://example.com/mammoth/snow",
      source_name: "Official snow report",
      extraction_method: "manual_seed",
      confidence: "high"
    )

    PassResortAccess.create!(
      pass_product: ikon,
      resort: mammoth,
      access_tier: "full_pass",
      unlimited_access: true
    )
    PassResortAccess.create!(
      pass_product: epic,
      resort: whistler,
      access_tier: "full_pass",
      unlimited_access: true
    )
  end

  it "filters resorts by search query" do
    get resorts_path(q: "mammoth")

    expect(response.body).to include("Mammoth Mountain")
    expect(response.body).not_to include("Whistler Blackcomb")
  end

  it "filters resorts by region" do
    get resorts_path(region: "Asia")

    expect(response.body).to include("Niseko United")
    expect(response.body).not_to include("Mammoth Mountain")
  end

  it "filters resorts by pass product" do
    get resorts_path(pass_product: "Epic Pass")

    expect(response.body).to include("Whistler Blackcomb")
    expect(response.body).not_to include("Mammoth Mountain")
  end

  it "filters resorts by minimum snow depth" do
    get resorts_path(snow_depth: "24")

    expect(response.body).to include("Mammoth Mountain")
    expect(response.body).not_to include("Whistler Blackcomb")
  end

  it "filters resorts by temperature range" do
    get resorts_path(temperature: "below_20")

    expect(response.body).to include("Mammoth Mountain")
    expect(response.body).not_to include("Whistler Blackcomb")
    expect(response.body).not_to include("Niseko United")
  end

  it "shows an empty state when no resorts match" do
    get resorts_path(q: "does-not-exist")

    expect(response.body).to include("No resorts match these filters")
  end

  def create_location_with_weather(resort, temperature:)
    location = ResortLocation.create!(
      resort: resort,
      name: "Primary Base",
      location_type: "base",
      latitude: 39.64,
      longitude: -106.37,
      is_primary: true
    )

    WeatherForecast.create!(
      resort_location: location,
      provider: "pirate_weather",
      forecast_type: "current",
      forecast_for: as_of,
      fetched_at: as_of,
      temperature: temperature,
      wind_speed: 8,
      precip_probability: 0,
      raw_data: {}
    )
  end
end
