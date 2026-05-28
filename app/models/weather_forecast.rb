# == Schema Information
#
# Table name: weather_forecasts
#
#  id                 :bigint           not null, primary key
#  cloud_cover        :decimal(5, 4)
#  fetched_at         :datetime         not null
#  forecast_for       :datetime         not null
#  forecast_type      :string           not null
#  precip_intensity   :decimal(8, 4)
#  precip_probability :decimal(5, 4)
#  precip_type        :string
#  provider           :string           not null
#  raw_data           :jsonb            not null
#  temperature        :decimal(8, 2)
#  temperature_high   :decimal(8, 2)
#  temperature_low    :decimal(8, 2)
#  wind_speed         :decimal(8, 2)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  resort_location_id :bigint           not null
#
# Indexes
#
#  idx_weather_forecasts_unique_location_period   (resort_location_id,provider,forecast_type,forecast_for) UNIQUE
#  index_weather_forecasts_on_resort_location_id  (resort_location_id)
#
# Foreign Keys
#
#  fk_rails_...  (resort_location_id => resort_locations.id)
#
class WeatherForecast < ApplicationRecord
  FORECAST_TYPES = %w[current daily].freeze
  belongs_to :resort_location

  validates :provider, presence: true
  validates :forecast_type, presence: true, inclusion: { in: FORECAST_TYPES }
  validates :forecast_for, presence: true
  validates :fetched_at, presence: true
end
