# == Schema Information
#
# Table name: resort_locations
#
#  id             :bigint           not null, primary key
#  elevation_feet :integer
#  is_primary     :boolean          default(FALSE), not null
#  latitude       :decimal(10, 6)   not null
#  location_type  :string           not null
#  longitude      :decimal(10, 6)   not null
#  name           :string           not null
#  notes          :text
#  source_url     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  resort_id      :bigint           not null
#
# Indexes
#
#  idx_resort_locations_one_primary_per_resort   (resort_id) UNIQUE WHERE (is_primary = true)
#  index_resort_locations_on_resort_id           (resort_id)
#  index_resort_locations_on_resort_id_and_name  (resort_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (resort_id => resorts.id)
#
class ResortLocation < ApplicationRecord
  LOCATION_TYPES = %w[
    base
    summit
    mid_mountain
    lodge
    snow_stake
    weather_station
    forecast_point
    other
  ].freeze
  
  belongs_to :resort

  has_many :weather_forecasts, dependent: :destroy
  has_many :snow_observations, dependent: :nullify
  has_one :current_weather_forecast,
    -> { where(forecast_type: "current").order(forecast_for: :desc) },
    class_name: "WeatherForecast"

  validates :name, presence: true
  validates :location_type, presence: true, inclusion: { in: LOCATION_TYPES }
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :is_primary, inclusion: { in: [true, false] }
end
