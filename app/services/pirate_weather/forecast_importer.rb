module PirateWeather
  class ForecastImporter
    PROVIDER = "pirate_weather"

    def initialize(client: Client.new)
      @client = client
    end

    def import_for_location!(resort_location)
      response = client.forecast_for(
        latitude: resort_location.latitude,
        longitude: resort_location.longitude
      )

      fetched_at = Time.current

      import_current!(resort_location, response.fetch("currently"), fetched_at)
      import_daily!(resort_location, response.fetch("daily").fetch("data"), fetched_at)
    end

    private

    attr_reader :client

    def import_current!(resort_location, current_data, fetched_at)
      forecast_for = Time.zone.at(current_data.fetch("time"))

      forecast = WeatherForecast.find_or_initialize_by(
        resort_location: resort_location,
        provider: PROVIDER,
        forecast_type: "current",
        forecast_for: forecast_for
      )

      forecast.update!(
        temperature: current_data["temperature"],
        wind_speed: current_data["windSpeed"],
        cloud_cover: current_data["cloudCover"],
        precip_type: current_data["precipType"],
        precip_probability: current_data["precipProbability"],
        fetched_at: fetched_at,
        raw_data: current_data
      )
    end

    def import_daily!(resort_location, daily_data, fetched_at)
      daily_data.first(7).each do |day_data|
        forecast_for = Time.zone.at(day_data.fetch("time"))

        forecast = WeatherForecast.find_or_initialize_by(
          resort_location: resort_location,
          provider: PROVIDER,
          forecast_type: "daily",
          forecast_for: forecast_for
        )

        forecast.update!(
          temperature_high: day_data["temperatureHigh"],
          temperature_low: day_data["temperatureLow"],
          wind_speed: day_data["windSpeed"],
          cloud_cover: day_data["cloudCover"],
          precip_type: day_data["precipType"],
          precip_probability: day_data["precipProbability"],
          fetched_at: fetched_at,
          raw_data: day_data
        )
      end
    end
  end
end
