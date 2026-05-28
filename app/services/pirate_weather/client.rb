require "http"

module PirateWeather
  class Client
    BASE_URL = ENV.fetch("PIRATE_WEATHER_API_URL", "https://prepend.me/api.pirateweather.net/forecast")

    def initialize(api_key: ENV.fetch("PIRATE_WEATHER_API_KEY"))
      @api_key = api_key
    end

    def forecast_for(latitude:, longitude:)
      response = HTTP
        .timeout(connect: 5, read: 15)
        .get(
          "#{BASE_URL}/#{api_key}/#{latitude},#{longitude}",
          params: {
            exclude: "minutely,hourly,alerts,flags",
            units: "us"
          }
        )

      raise "Pirate Weather request failed: #{response.status}" unless response.status.success?

      JSON.parse(response.body.to_s)          
    end

    private

    attr_reader :api_key
  end
end
