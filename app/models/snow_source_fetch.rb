# == Schema Information
#
# Table name: snow_source_fetches
#
#  id                    :bigint           not null, primary key
#  content_type          :string
#  error_message         :text
#  fetched_at            :datetime         not null
#  http_status           :integer
#  raw_text              :text
#  response_sha256       :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  snow_report_source_id :bigint           not null
#
# Indexes
#
#  idx_snow_fetches_source_fetched_at                  (snow_report_source_id,fetched_at)
#  index_snow_source_fetches_on_response_sha256        (response_sha256)
#  index_snow_source_fetches_on_snow_report_source_id  (snow_report_source_id)
#
# Foreign Keys
#
#  fk_rails_...  (snow_report_source_id => snow_report_sources.id)
#
class SnowSourceFetch < ApplicationRecord
  belongs_to :snow_report_source

  validates :fetched_at, presence: true
  validates :http_status, numericality: { only_integer: true }, allow_nil: true
end
