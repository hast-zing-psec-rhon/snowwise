class CreateWeatherForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :weather_forecasts do |t|
      t.references :resort_location, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :forecast_type, null: false
      t.datetime :forecast_for, null: false
      t.decimal :temperature, precision: 8, scale: 2
      t.decimal :temperature_high, precision: 8, scale: 2
      t.decimal :temperature_low, precision: 8, scale: 2
      t.decimal :wind_speed, precision: 8, scale: 2
      t.decimal :cloud_cover, precision: 5, scale: 4
      t.string :precip_type
      t.decimal :precip_probability, precision: 5, scale: 4
      t.decimal :precip_intensity, precision: 8, scale: 4
      t.datetime :fetched_at, null: false
      t.jsonb :raw_data, null: false, default: {}

      t.timestamps
    end

    add_index :weather_forecasts,
      [:resort_location_id, :provider, :forecast_type, :forecast_for],
      unique: true,
      name: "idx_weather_forecasts_unique_location_period"
  end
end
