class CreateSnowObservations < ActiveRecord::Migration[8.0]
  def change
    create_table :snow_observations do |t|
      t.references :resort, null: false, foreign_key: true
      t.references :resort_location, null: true, foreign_key: true
      t.references :snow_report_source, null: false, foreign_key: true
      t.datetime :observed_at
      t.datetime :queried_at, null: false
      t.decimal :base_depth_inches, precision: 6, scale: 2
      t.decimal :mid_depth_inches, precision: 6, scale: 2
      t.decimal :upper_depth_inches, precision: 6, scale: 2
      t.decimal :new_snow_24h_inches, precision: 6, scale: 2
      t.decimal :new_snow_48h_inches, precision: 6, scale: 2
      t.decimal :new_snow_7d_inches, precision: 6, scale: 2
      t.string :operating_status
      t.string :zero_depth_reason
      t.string :surface_condition
      t.string :source_url, null: false
      t.string :source_name, null: false
      t.string :extraction_method, null: false
      t.string :confidence, null: false
      t.text :source_evidence
      t.text :notes

      t.timestamps
    end

    add_index :snow_observations, [:resort_id, :snow_report_source_id, :observed_at],
      unique: true,
      name: "idx_snow_observations_unique_source_time"

    add_index :snow_observations, [:resort_id, :queried_at],
      name: "idx_snow_observations_resort_queried_at"
  end
end
