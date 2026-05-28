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
require "rails_helper"

RSpec.describe ResortConditionScore, type: :model do
  describe "associations" do
    it { should belong_to(:resort) }
    it { should belong_to(:snow_observation).optional }
    it { should belong_to(:weather_forecast).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:label) }
    it { should validate_presence_of(:data_quality) }
    it { should validate_presence_of(:calculated_at) }

    it do
      should validate_numericality_of(:score)
        .only_integer
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(100)
        .allow_nil
    end
  end

  describe "#to_result" do
    it "converts the saved score into a score calculator result" do
      resort = Resort.create!(name: "Example Mountain", country: "United States")
      score = described_class.create!(
        resort: resort,
        score: 72,
        label: "Good",
        data_quality: "good",
        reasons: ["strong_base"],
        calculated_at: Time.zone.local(2026, 5, 27, 12, 0, 0)
      )

      result = score.to_result

      expect(result.score).to eq(72)
      expect(result.label).to eq("Good")
      expect(result.data_quality).to eq("good")
      expect(result.reasons).to eq([:strong_base])
    end
  end
end
