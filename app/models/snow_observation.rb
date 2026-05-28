# == Schema Information
#
# Table name: snow_observations
#
#  id                    :bigint           not null, primary key
#  base_depth_inches     :decimal(6, 2)
#  confidence            :string           not null
#  extraction_method     :string           not null
#  mid_depth_inches      :decimal(6, 2)
#  new_snow_24h_inches   :decimal(6, 2)
#  new_snow_48h_inches   :decimal(6, 2)
#  new_snow_7d_inches    :decimal(6, 2)
#  notes                 :text
#  observed_at           :datetime
#  operating_status      :string
#  queried_at            :datetime         not null
#  source_evidence       :text
#  source_name           :string           not null
#  source_url            :string           not null
#  surface_condition     :string
#  upper_depth_inches    :decimal(6, 2)
#  zero_depth_reason     :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  resort_id             :bigint           not null
#  resort_location_id    :bigint
#  snow_report_source_id :bigint           not null
#
# Indexes
#
#  idx_snow_observations_resort_queried_at           (resort_id,queried_at)
#  idx_snow_observations_unique_source_time          (resort_id,snow_report_source_id,observed_at) UNIQUE
#  index_snow_observations_on_resort_id              (resort_id)
#  index_snow_observations_on_resort_location_id     (resort_location_id)
#  index_snow_observations_on_snow_report_source_id  (snow_report_source_id)
#
# Foreign Keys
#
#  fk_rails_...  (resort_id => resorts.id)
#  fk_rails_...  (resort_location_id => resort_locations.id)
#  fk_rails_...  (snow_report_source_id => snow_report_sources.id)
#
class SnowObservation < ApplicationRecord
  CONFIDENCE_LEVELS = %w[
    high
    medium
    low
  ].freeze

  EXTRACTION_METHODS = %w[
    deterministic
    openai
    manual_seed
    fallback_aggregator
  ].freeze

  OPERATING_STATUSES = %w[
    open
    closed
    preseason
    offseason
    summer_operations
    unknown
  ].freeze

  ZERO_DEPTH_REASONS = %w[
    explicit_zero
    closed
    preseason
    offseason
    summer_operations
    no_snow
  ].freeze

  belongs_to :resort
  belongs_to :resort_location, optional: true
  belongs_to :snow_report_source

  validates :queried_at, presence: true
  validates :source_name, presence: true
  validates :source_url, presence: true
  validates :extraction_method, presence: true, inclusion: { in: EXTRACTION_METHODS }
  validates :confidence, presence: true, inclusion: { in: CONFIDENCE_LEVELS }
  validates :operating_status, inclusion: { in: OPERATING_STATUSES }, allow_nil: true
  validates :zero_depth_reason, inclusion: { in: ZERO_DEPTH_REASONS }, allow_nil: true

  validates :base_depth_inches,
    :mid_depth_inches,
    :upper_depth_inches,
    :new_snow_24h_inches,
    :new_snow_48h_inches,
    :new_snow_7d_inches,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000 },
    allow_nil: true
end
