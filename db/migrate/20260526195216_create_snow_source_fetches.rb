class CreateSnowSourceFetches < ActiveRecord::Migration[8.0]
  def change
    create_table :snow_source_fetches do |t|
      t.references :snow_report_source, null: false, foreign_key: true
      t.datetime :fetched_at, null: false
      t.integer :http_status
      t.string :content_type
      t.string :response_sha256
      t.text :raw_text
      t.text :error_message

      t.timestamps
    end

    add_index :snow_source_fetches, [:snow_report_source_id, :fetched_at],
      name: "idx_snow_fetches_source_fetched_at"

    add_index :snow_source_fetches, :response_sha256
  end
end
