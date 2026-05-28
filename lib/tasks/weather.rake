namespace :weather do
  desc "Refresh Pirate Weather forecast for one resort location"
  task refresh_one: :environment do
    location = ResortLocation
      .includes(:resort)
      .order(:id)
      .first

    if location.nil?
      puts "No resort locations found. Run bin/rails seed_data:import first."
      exit 1
    end

    PirateWeather::ForecastImporter
      .new
      .import_for_location!(location)

    Conditions::RefreshScore.call(resort: location.resort)

    puts "Imported Pirate Weather forecast for #{location.resort.name} - #{location.name}."
    puts "Refreshed condition score for #{location.resort.name}."
  end

  desc "Refresh Pirate Weather forecasts for all resort locations"
  task refresh_all: :environment do
    locations = ResortLocation
      .includes(:resort)
      .order(:id)

    importer = PirateWeather::ForecastImporter.new

    succeeded = 0
    failed = 0

    locations.find_each do |location|
      begin
        importer.import_for_location!(location)
        succeeded += 1

        puts "Imported #{location.resort.name} - #{location.name}"
      rescue StandardError => error
        failed += 1

        warn "Failed #{location.resort.name} - #{location.name}: #{error.class} - #{error.message}"
      end
    end

    refreshed_count = Conditions::RefreshAllScores.call

    puts "Weather refresh complete. Succeeded: #{succeeded}. Failed: #{failed}."
    puts "Refreshed #{refreshed_count} resort condition scores."
  end
end
