class MapsController < ApplicationController
  def show
    @resorts = Resort
      .includes(
        :resort_groups,
        :latest_snow_observation,
        primary_location: :weather_forecasts
      )
      .where.not(latitude: nil, longitude: nil)
      .order(:country, :state_or_region, :name)
      .to_a

    @map_resorts = @resorts.map { |resort| ResortMapMarker.new(resort).as_json }
    @map_regions = @map_resorts.map { |resort| resort[:region] }.compact.uniq.sort
    @map_summary = build_summary(@map_resorts)
  end

  private

  def build_summary(map_resorts)
    eligible_resorts = map_resorts.select { |resort| resort[:open_status] == "open" }
    candidates = eligible_resorts.presence || map_resorts

    {
      resort_count: map_resorts.size,
      best_conditions: candidates.max_by { |resort| resort[:conditions_score].to_i },
      most_forecast_snow: candidates.max_by { |resort| resort[:forecast_snow_7d_inches].to_f },
      best_ikon: candidates.select { |resort| resort[:pass_types].include?("Ikon") }.max_by { |resort| resort[:conditions_score].to_i },
      best_epic: candidates.select { |resort| resort[:pass_types].include?("Epic") }.max_by { |resort| resort[:conditions_score].to_i }
    }
  end
end
