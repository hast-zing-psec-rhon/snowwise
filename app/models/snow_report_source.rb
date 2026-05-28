# == Schema Information
#
# Table name: snow_report_sources
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  notes           :text
#  parser_strategy :string           default("openai_text_extraction"), not null
#  priority        :integer          default(100), not null
#  provider_name   :string           not null
#  source_name     :string           not null
#  source_type     :string           not null
#  source_url      :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  resort_id       :bigint           not null
#
# Indexes
#
#  idx_snow_sources_unique_resort_url      (resort_id,source_url) UNIQUE
#  index_snow_report_sources_on_resort_id  (resort_id)
#
# Foreign Keys
#
#  fk_rails_...  (resort_id => resorts.id)
#
class SnowReportSource < ApplicationRecord
  SOURCE_TYPES = %w[
    official_resort
    aggregator
    government
    other
  ].freeze

  PARSER_STRATEGIES = %w[
    deterministic
    openai_text_extraction
    html_text_extraction
    pdf_text_extraction
  ].freeze

  belongs_to :resort

  has_many :snow_source_fetches, dependent: :destroy
  has_many :snow_observations, dependent: :destroy

  validates :provider_name, presence: true
  validates :source_name, presence: true
  validates :source_url, presence: true
  validates :source_type, presence: true, inclusion: { in: SOURCE_TYPES }
  validates :parser_strategy, presence: true, inclusion: { in: PARSER_STRATEGIES }
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }
end
