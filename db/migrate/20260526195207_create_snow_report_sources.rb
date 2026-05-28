class CreateSnowReportSources < ActiveRecord::Migration[8.0]
  def change
    create_table :snow_report_sources do |t|
      t.references :resort, null: false, foreign_key: true
      t.string :provider_name, null: false
      t.string :source_name, null: false
      t.string :source_url, null: false
      t.string :source_type, null: false
      t.integer :priority, null: false, default: 100
      t.string :parser_strategy, null: false, default: "openai_text_extraction"
      t.boolean :active, null: false, default: true
      t.text :notes

      t.timestamps
    end

    add_index :snow_report_sources, [:resort_id, :source_url],
      unique: true,
      name: "idx_snow_sources_unique_resort_url"

  end
end
