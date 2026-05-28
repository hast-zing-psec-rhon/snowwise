class ResortsController < ApplicationController
  PASS_FILTER_NAMES = ["Epic Pass", "Ikon Pass"].freeze
  REGION_ORDER = ["North America", "Europe", "Asia", "Oceania", "South America"].freeze
  PAGE_SIZE = 40
SNOW_DEPTH_OPTIONS = {
  "12" => "1 foot+",
  "24" => "2 feet+",
  "48" => "4 feet+",
  "72" => "6 feet+",
  "96" => "8 feet+"
}.freeze
  TEMPERATURE_OPTIONS = {
    "below_20" => "Below 20°F",
    "20_to_32" => "20°F to 32°F",
    "above_32" => "Above 32°F"
  }.freeze
  SORT_OPTIONS = {
    "condition_score" => "Best Conditions",
    "name_asc" => "A-Z",
    "name_desc" => "Z-A"
  }.freeze

  REGION_BY_COUNTRY = {
    "Andorra" => "Europe",
    "Australia" => "Oceania",
    "Austria" => "Europe",
    "Canada" => "North America",
    "Chile" => "South America",
    "China" => "Asia",
    "France" => "Europe",
    "Italy" => "Europe",
    "Japan" => "Asia",
    "New Zealand" => "Oceania",
    "South Korea" => "Asia",
    "Switzerland" => "Europe",
    "United States" => "North America"
  }.freeze

  def index
    @pass_products = PassProduct
      .where(name: PASS_FILTER_NAMES)
      .order(:name)

    @selected_pass_product = @pass_products.find do |pass_product|
      pass_product.name == params[:pass_product]
    end

    @regions = REGION_ORDER
    @snow_depth_options = SNOW_DEPTH_OPTIONS
    @temperature_options = TEMPERATURE_OPTIONS
    @search_query = params[:q].to_s.strip
    @selected_region = selected_region
    @selected_snow_depth = selected_snow_depth
    @selected_temperature = selected_temperature
    @sort_options = SORT_OPTIONS
    @selected_sort = selected_sort
    @current_page = current_page
    @per_page = PAGE_SIZE

    all_resorts = sort_resorts(apply_filters(load_resorts))
    @total_resort_count = all_resorts.size
    @total_pages = (@total_resort_count.to_f / @per_page).ceil
    @resorts = paginate_resorts(all_resorts)
    @condition_score_results = build_condition_score_results(@resorts)
    @resort_card_data = build_resort_card_data(@resorts, @condition_score_results)
    @resorts_by_region = group_resorts_by_region(@resorts)
  end

  private

  def load_resorts
    resorts = Resort
      .includes(
        :resort_groups,
        :latest_snow_observation,
        :resort_condition_score,
        primary_location: :weather_forecasts
      )
      .order(:country, :state_or_region, :name)

    if @selected_pass_product.present?
      resorts = resorts.where(id: eligible_resort_ids)
    end

    resorts.to_a
  end

  def apply_filters(resorts)
    resorts = filter_by_search(resorts)
    resorts = filter_by_region(resorts)
    resorts = filter_by_snow_depth(resorts)
    filter_by_temperature(resorts)
  end

  def filter_by_search(resorts)
    return resorts if @search_query.blank?

    query = @search_query.downcase

    resorts.select do |resort|
      [resort.name, resort.city, resort.state_or_region, resort.country]
        .compact
        .any? { |value| value.downcase.include?(query) }
    end
  end

  def filter_by_region(resorts)
    return resorts if @selected_region.blank?

    resorts.select do |resort|
      REGION_BY_COUNTRY[resort.country] == @selected_region
    end
  end

  def filter_by_snow_depth(resorts)
    return resorts if @selected_snow_depth.blank?

    minimum_inches = @selected_snow_depth.to_d

    resorts.select do |resort|
      resort.latest_snow_observation&.base_depth_inches.to_d >= minimum_inches
    end
  end

  def filter_by_temperature(resorts)
    return resorts if @selected_temperature.blank?

    resorts.select do |resort|
      temperature = current_forecast_for(resort)&.temperature
      next false if temperature.blank?

      case @selected_temperature
      when "below_20"
        temperature < 20
      when "20_to_32"
        temperature >= 20 && temperature <= 32
      when "above_32"
        temperature > 32
      else
        true
      end
    end
  end

  def eligible_resort_ids
    direct_resort_ids = PassResortAccess
      .where(pass_product: @selected_pass_product)
      .where.not(resort_id: nil)
      .select(:resort_id)

    group_ids = PassResortAccess
      .where(pass_product: @selected_pass_product)
      .where.not(resort_group_id: nil)
      .select(:resort_group_id)

    group_resort_ids = ResortGroupMembership
      .where(resort_group_id: group_ids)
      .select(:resort_id)

    Resort
      .where(id: direct_resort_ids)
      .or(Resort.where(id: group_resort_ids))
      .select(:id)
  end

  def selected_region
    REGION_ORDER.include?(params[:region]) ? params[:region] : nil
  end

  def selected_snow_depth
    SNOW_DEPTH_OPTIONS.key?(params[:snow_depth]) ? params[:snow_depth] : nil
  end

  def selected_temperature
    TEMPERATURE_OPTIONS.key?(params[:temperature]) ? params[:temperature] : nil
  end

  def selected_sort
    SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : "condition_score"
  end

  def current_page
    page = params[:page].to_i
    page.positive? ? page : 1
  end

  def paginate_resorts(resorts)
    resorts.slice((@current_page - 1) * @per_page, @per_page) || []
  end

  def sort_resorts(resorts)
    score_results = build_condition_score_results(resorts)

    case @selected_sort
    when "name_asc"
      resorts.sort_by { |resort| resort.name.downcase }
    when "name_desc"
      resorts.sort_by { |resort| resort.name.downcase }.reverse
    else
      resorts.sort_by do |resort|
        score = score_results.fetch(resort.id).score
        score.present? ? [0, -score, resort.name.downcase] : [1, 0, resort.name.downcase]
      end
    end
  end

  def build_condition_score_results(resorts)
    resorts.index_with do |resort|
      persisted_score_result_for(resort) || calculated_score_result_for(resort)
    end.transform_keys(&:id)
  end

  def persisted_score_result_for(resort)
    resort.resort_condition_score&.to_result
  end

  def calculated_score_result_for(resort)
    Rails.cache.fetch(calculated_score_cache_key(resort), expires_in: 12.hours) do
      Conditions::ScoreCalculator.call(
        resort: resort,
        snow_observation: resort.latest_snow_observation,
        weather_forecast: current_forecast_for(resort),
        daily_forecasts: daily_forecasts_for(resort)
      )
    end
  end

  def calculated_score_cache_key(resort)
    [
      "calculated-condition-score-v1",
      resort.cache_key_with_version,
      resort.latest_snow_observation&.cache_key_with_version,
      current_forecast_for(resort)&.cache_key_with_version,
      daily_forecasts_for(resort).map(&:cache_key_with_version)
    ]
  end

  def build_resort_card_data(resorts, score_results)
    access_map = build_pass_access_map(resorts)

    resorts.index_with do |resort|
      current_forecast = current_forecast_for(resort)
      daily_forecasts = daily_forecasts_for(resort)
      accesses = access_map.fetch(resort.id, [])

      {
        current_forecast: current_forecast,
        daily_forecasts: daily_forecasts,
        score_result: score_results.fetch(resort.id),
        accesses: accesses,
        cache_key: resort_card_cache_key(resort, current_forecast, daily_forecasts, accesses)
      }
    end.transform_keys(&:id)
  end

  def build_pass_access_map(resorts)
    resort_ids = resorts.map(&:id)
    group_ids_by_resort_id = resorts.to_h do |resort|
      [resort.id, resort.resort_groups.map(&:id)]
    end
    group_ids = group_ids_by_resort_id.values.flatten.uniq

    access_map = Hash.new { |hash, resort_id| hash[resort_id] = [] }

    PassResortAccess
      .includes(:pass_product, :resort_group)
      .where(resort_id: resort_ids)
      .find_each do |access|
        access_map[access.resort_id] << access
      end

    if group_ids.any?
      grouped_accesses = PassResortAccess
        .includes(:pass_product, :resort_group)
        .where(resort_group_id: group_ids)
        .to_a

      group_ids_by_resort_id.each do |resort_id, resort_group_ids|
        grouped_accesses.each do |access|
          access_map[resort_id] << access if resort_group_ids.include?(access.resort_group_id)
        end
      end
    end

    access_map.transform_values do |accesses|
      accesses.uniq.sort_by { |access| access.pass_product.name }
    end
  end

  def resort_card_cache_key(resort, current_forecast, daily_forecasts, accesses)
    [
      "resort-card-v5",
      resort.cache_key_with_version,
      resort.latest_snow_observation&.cache_key_with_version,
      resort.resort_condition_score&.cache_key_with_version,
      current_forecast&.cache_key_with_version,
      daily_forecasts.map(&:cache_key_with_version),
      accesses.map(&:cache_key_with_version)
    ]
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

  def group_resorts_by_region(resorts)
    grouped_resorts = REGION_ORDER.index_with { [] }

    resorts.each do |resort|
      region = REGION_BY_COUNTRY.fetch(resort.country)
      grouped_resorts[region] << resort
    end

    grouped_resorts
  end
end
