require "csv"

module Conditions
  class BaselineLookup
    Baseline = Struct.new(
      :region,
      :country,
      :state_or_region,
      :month,
      :baseline_base_depth_inches,
      :good_base_depth_inches,
      :excellent_base_depth_inches,
      keyword_init: true
    )

    DEFAULT_BASELINE = Baseline.new(
      region: "Default",
      country: nil,
      state_or_region: nil,
      month: nil,
      baseline_base_depth_inches: 12.0,
      good_base_depth_inches: 36.0,
      excellent_base_depth_inches: 60.0
    )

    def self.call(resort:, month:, csv_path: Rails.root.join("data/condition_score_baselines.csv"))
      new(csv_path).call(resort: resort, month: month)
    end

    def initialize(csv_path)
      @csv_path = csv_path
    end

    def call(resort:, month:)
      exact_match(resort, month) || country_match(resort, month) || DEFAULT_BASELINE
    end

    private

    attr_reader :csv_path

    def exact_match(resort, month)
      rows.find do |baseline|
        baseline.month == month &&
          baseline.country == resort.country &&
          baseline.state_or_region == resort.state_or_region
      end
    end

    def country_match(resort, month)
      rows.find do |baseline|
        baseline.month == month &&
          baseline.country == resort.country &&
          baseline.state_or_region.blank?
      end
    end

    def rows
      @rows ||= CSV.read(csv_path, headers: true).map do |row|
        Baseline.new(
          region: row.fetch("region"),
          country: row["country"].presence,
          state_or_region: row["state_or_region"].presence,
          month: row.fetch("month").to_i,
          baseline_base_depth_inches: row.fetch("baseline_base_depth_inches").to_f,
          good_base_depth_inches: row.fetch("good_base_depth_inches").to_f,
          excellent_base_depth_inches: row.fetch("excellent_base_depth_inches").to_f
        )
      end
    rescue Errno::ENOENT
      [DEFAULT_BASELINE]
    end
  end
end
