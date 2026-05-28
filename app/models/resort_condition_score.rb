# == Schema Information
#
# Table name: resort_condition_scores
#
#  id                  :bigint           not null, primary key
#  calculated_at       :datetime         not null
#  data_quality        :string           not null
#  label               :string           not null
#  reasons             :jsonb            not null
#  score               :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  resort_id           :bigint           not null
#  snow_observation_id :bigint
#  weather_forecast_id :bigint
#
# Indexes
#
#  index_resort_condition_scores_on_resort_id            (resort_id) UNIQUE
#  index_resort_condition_scores_on_snow_observation_id  (snow_observation_id)
#  index_resort_condition_scores_on_weather_forecast_id  (weather_forecast_id)
#
# Foreign Keys
#
#  fk_rails_...  (resort_id => resorts.id)
#  fk_rails_...  (snow_observation_id => snow_observations.id)
#  fk_rails_...  (weather_forecast_id => weather_forecasts.id)
#
class ResortConditionScore < ApplicationRecord
  belongs_to :resort
  belongs_to :snow_observation, optional: true
  belongs_to :weather_forecast, optional: true

  validates :label, presence: true
  validates :data_quality, presence: true
  validates :calculated_at, presence: true
  validates :score,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
    allow_nil: true

  def to_result
    Conditions::ScoreCalculator::Result.new(
      score: score,
      label: label,
      reasons: reasons.map(&:to_sym),
      data_quality: data_quality
    )
  end
end
