require "rails_helper"

RSpec.describe "Snowwise map", type: :request do
  it "renders the map page and serializes resort marker data" do
    ikon = PassProduct.create!(name: "Ikon Pass", season: "2026-2027")
    resort = Resort.create!(
      name: "Alta Ski Area",
      country: "United States",
      state_or_region: "Utah",
      city: "Alta",
      latitude: 40.589556,
      longitude: -111.636637
    )

    ResortLocation.create!(
      resort: resort,
      name: "Base Weather",
      location_type: "base",
      latitude: 40.589556,
      longitude: -111.636637,
      is_primary: true
    )

    PassResortAccess.create!(
      pass_product: ikon,
      resort: resort,
      access_tier: "full_pass",
      unlimited_access: true,
      reservation_required: false,
      blackout_dates_apply: false
    )

    get map_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Map | Snowwise")
    expect(response.body).to include("data-controller=\"resort-map\"")
    expect(response.body).to include("Interactive ski resort map")
    expect(response.body).to include("Filter resorts")
    expect(response.body).to include("Alta Ski Area")
    expect(response.body).to include("Ikon")
  end
end
