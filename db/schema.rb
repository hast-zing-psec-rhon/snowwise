# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_05_27_010000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "pass_products", force: :cascade do |t|
    t.string "name", null: false
    t.string "company_name"
    t.string "season"
    t.string "website_url"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "season"], name: "index_pass_products_on_name_and_season", unique: true
  end

  create_table "pass_resort_accesses", force: :cascade do |t|
    t.bigint "pass_product_id", null: false
    t.bigint "resort_id"
    t.string "access_tier", null: false
    t.integer "access_days"
    t.boolean "unlimited_access", default: false, null: false
    t.boolean "reservation_required", default: false, null: false
    t.boolean "blackout_dates_apply", default: false, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "resort_group_id"
    t.index ["pass_product_id", "resort_group_id", "access_tier"], name: "idx_pass_access_unique_resort_group", unique: true, where: "(resort_group_id IS NOT NULL)"
    t.index ["pass_product_id", "resort_id", "access_tier"], name: "idx_pass_access_unique_resort", unique: true, where: "(resort_id IS NOT NULL)"
    t.index ["pass_product_id"], name: "index_pass_resort_accesses_on_pass_product_id"
    t.index ["resort_group_id"], name: "index_pass_resort_accesses_on_resort_group_id"
    t.index ["resort_id"], name: "index_pass_resort_accesses_on_resort_id"
    t.check_constraint "resort_id IS NOT NULL AND resort_group_id IS NULL OR resort_id IS NULL AND resort_group_id IS NOT NULL", name: "pass_access_exactly_one_target"
  end

  create_table "resort_condition_scores", force: :cascade do |t|
    t.bigint "resort_id", null: false
    t.bigint "snow_observation_id"
    t.bigint "weather_forecast_id"
    t.integer "score"
    t.string "label", null: false
    t.string "data_quality", null: false
    t.jsonb "reasons", default: [], null: false
    t.datetime "calculated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id"], name: "index_resort_condition_scores_on_resort_id", unique: true
    t.index ["snow_observation_id"], name: "index_resort_condition_scores_on_snow_observation_id"
    t.index ["weather_forecast_id"], name: "index_resort_condition_scores_on_weather_forecast_id"
    t.check_constraint "score IS NULL OR score >= 0 AND score <= 100", name: "resort_condition_scores_score_range"
  end

  create_table "resort_group_memberships", force: :cascade do |t|
    t.bigint "resort_group_id", null: false
    t.bigint "resort_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_group_id", "resort_id"], name: "idx_on_resort_group_id_resort_id_a650f73668", unique: true
    t.index ["resort_group_id"], name: "index_resort_group_memberships_on_resort_group_id"
    t.index ["resort_id"], name: "index_resort_group_memberships_on_resort_id"
  end

  create_table "resort_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "country"
    t.string "state_or_region"
    t.string "website_url"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "country", "state_or_region"], name: "index_resort_groups_on_name_and_country_and_state_or_region", unique: true
  end

  create_table "resort_locations", force: :cascade do |t|
    t.bigint "resort_id", null: false
    t.string "name", null: false
    t.string "location_type", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.integer "elevation_feet"
    t.boolean "is_primary", default: false, null: false
    t.text "notes"
    t.string "source_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id", "name"], name: "index_resort_locations_on_resort_id_and_name", unique: true
    t.index ["resort_id"], name: "idx_resort_locations_one_primary_per_resort", unique: true, where: "(is_primary = true)"
    t.index ["resort_id"], name: "index_resort_locations_on_resort_id"
  end

  create_table "resorts", force: :cascade do |t|
    t.string "name", null: false
    t.string "country", null: false
    t.string "state_or_region"
    t.string "city"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "website_url"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "image_type"
    t.string "image_credit"
    t.string "image_source_url"
    t.index ["name", "country", "state_or_region"], name: "index_resorts_on_name_and_country_and_state_or_region", unique: true
  end

  create_table "snow_observations", force: :cascade do |t|
    t.bigint "resort_id", null: false
    t.bigint "resort_location_id"
    t.bigint "snow_report_source_id", null: false
    t.datetime "observed_at"
    t.datetime "queried_at", null: false
    t.decimal "base_depth_inches", precision: 6, scale: 2
    t.decimal "mid_depth_inches", precision: 6, scale: 2
    t.decimal "upper_depth_inches", precision: 6, scale: 2
    t.decimal "new_snow_24h_inches", precision: 6, scale: 2
    t.decimal "new_snow_48h_inches", precision: 6, scale: 2
    t.decimal "new_snow_7d_inches", precision: 6, scale: 2
    t.string "operating_status"
    t.string "zero_depth_reason"
    t.string "surface_condition"
    t.string "source_url", null: false
    t.string "source_name", null: false
    t.string "extraction_method", null: false
    t.string "confidence", null: false
    t.text "source_evidence"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id", "queried_at"], name: "idx_snow_observations_resort_queried_at"
    t.index ["resort_id", "snow_report_source_id", "observed_at"], name: "idx_snow_observations_unique_source_time", unique: true
    t.index ["resort_id"], name: "index_snow_observations_on_resort_id"
    t.index ["resort_location_id"], name: "index_snow_observations_on_resort_location_id"
    t.index ["snow_report_source_id"], name: "index_snow_observations_on_snow_report_source_id"
  end

  create_table "snow_refresh_runs", force: :cascade do |t|
    t.datetime "started_at", null: false
    t.string "status", default: "running", null: false
    t.integer "resorts_attempted", default: 0, null: false
    t.integer "observations_created", default: 0, null: false
    t.integer "error_count", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "finished_at"
    t.index ["started_at"], name: "index_snow_refresh_runs_on_started_at"
    t.index ["status"], name: "index_snow_refresh_runs_on_status"
  end

  create_table "snow_report_sources", force: :cascade do |t|
    t.bigint "resort_id", null: false
    t.string "provider_name", null: false
    t.string "source_name", null: false
    t.string "source_url", null: false
    t.string "source_type", null: false
    t.integer "priority", default: 100, null: false
    t.string "parser_strategy", default: "openai_text_extraction", null: false
    t.boolean "active", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id", "source_url"], name: "idx_snow_sources_unique_resort_url", unique: true
    t.index ["resort_id"], name: "index_snow_report_sources_on_resort_id"
  end

  create_table "snow_source_fetches", force: :cascade do |t|
    t.bigint "snow_report_source_id", null: false
    t.datetime "fetched_at", null: false
    t.integer "http_status"
    t.string "content_type"
    t.string "response_sha256"
    t.text "raw_text"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_sha256"], name: "index_snow_source_fetches_on_response_sha256"
    t.index ["snow_report_source_id", "fetched_at"], name: "idx_snow_fetches_source_fetched_at"
    t.index ["snow_report_source_id"], name: "index_snow_source_fetches_on_snow_report_source_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "weather_forecasts", force: :cascade do |t|
    t.bigint "resort_location_id", null: false
    t.string "provider", null: false
    t.string "forecast_type", null: false
    t.datetime "forecast_for", null: false
    t.decimal "temperature", precision: 8, scale: 2
    t.decimal "temperature_high", precision: 8, scale: 2
    t.decimal "temperature_low", precision: 8, scale: 2
    t.decimal "wind_speed", precision: 8, scale: 2
    t.decimal "cloud_cover", precision: 5, scale: 4
    t.string "precip_type"
    t.decimal "precip_probability", precision: 5, scale: 4
    t.decimal "precip_intensity", precision: 8, scale: 4
    t.datetime "fetched_at", null: false
    t.jsonb "raw_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_location_id", "provider", "forecast_type", "forecast_for"], name: "idx_weather_forecasts_unique_location_period", unique: true
    t.index ["resort_location_id"], name: "index_weather_forecasts_on_resort_location_id"
  end

  add_foreign_key "pass_resort_accesses", "pass_products"
  add_foreign_key "pass_resort_accesses", "resort_groups"
  add_foreign_key "pass_resort_accesses", "resorts"
  add_foreign_key "resort_condition_scores", "resorts"
  add_foreign_key "resort_condition_scores", "snow_observations"
  add_foreign_key "resort_condition_scores", "weather_forecasts"
  add_foreign_key "resort_group_memberships", "resort_groups"
  add_foreign_key "resort_group_memberships", "resorts"
  add_foreign_key "resort_locations", "resorts"
  add_foreign_key "snow_observations", "resort_locations"
  add_foreign_key "snow_observations", "resorts"
  add_foreign_key "snow_observations", "snow_report_sources"
  add_foreign_key "snow_report_sources", "resorts"
  add_foreign_key "snow_source_fetches", "snow_report_sources"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "weather_forecasts", "resort_locations"
end
