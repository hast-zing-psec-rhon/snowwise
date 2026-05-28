module Conditions
  class RefreshAllScores
    def self.call(scope: Resort.all, as_of: Time.current)
      new(scope: scope, as_of: as_of).call
    end

    def initialize(scope:, as_of:)
      @scope = scope
      @as_of = as_of
    end

    def call
      refreshed_count = 0

      scope.includes(
        :latest_snow_observation,
        primary_location: :weather_forecasts
      ).find_each do |resort|
        RefreshScore.call(resort: resort, as_of: as_of)
        refreshed_count += 1
      end

      refreshed_count
    end

    private

    attr_reader :scope, :as_of
  end
end
