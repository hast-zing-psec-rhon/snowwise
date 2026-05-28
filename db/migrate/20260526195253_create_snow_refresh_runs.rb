class CreateSnowRefreshRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :snow_refresh_runs do |t|
     t.datetime :started_at, null: false
      t.string :status, null: false, default: "running"
      t.integer :resorts_attempted, null: false, default: 0
      t.integer :observations_created, null: false, default: 0
      t.integer :error_count, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :snow_refresh_runs, :started_at
    add_index :snow_refresh_runs, :status
  end
end
