class AddFinishedAtToSnowRefreshRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :snow_refresh_runs, :finished_at, :datetime
  end
end
