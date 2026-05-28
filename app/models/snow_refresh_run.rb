# == Schema Information
#
# Table name: snow_refresh_runs
#
#  id                   :bigint           not null, primary key
#  error_count          :integer          default(0), not null
#  finished_at          :datetime
#  notes                :text
#  observations_created :integer          default(0), not null
#  resorts_attempted    :integer          default(0), not null
#  started_at           :datetime         not null
#  status               :string           default("running"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_snow_refresh_runs_on_started_at  (started_at)
#  index_snow_refresh_runs_on_status      (status)
#
class SnowRefreshRun < ApplicationRecord
  STATUSES = %w[
    running
    succeeded
    failed
    partial
  ].freeze

  validates :started_at, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :resorts_attempted, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :observations_created, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :error_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
