class CreateResortConditionScores < ActiveRecord::Migration[8.0]
  def change
    create_table :resort_condition_scores do |t|
      t.references :resort, null: false, foreign_key: true, index: { unique: true }
      t.references :snow_observation, foreign_key: true
      t.references :weather_forecast, foreign_key: true
      t.integer :score
      t.string :label, null: false
      t.string :data_quality, null: false
      t.jsonb :reasons, null: false, default: []
      t.datetime :calculated_at, null: false

      t.timestamps
    end

    add_check_constraint :resort_condition_scores,
      "score IS NULL OR (score >= 0 AND score <= 100)",
      name: "resort_condition_scores_score_range"
  end
end
