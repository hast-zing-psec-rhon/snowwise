namespace :seed_data do
  desc "Validate seed CSV files"
  task validate: :environment do
    importer = SeedData::CsvImporter.new

    if importer.valid?
      puts "Seed CSVs are valid."
    else
      puts importer.errors.join("\n")
      exit 1
    end
  end

  desc "Import seed CSV files"
  task import: :environment do
    SeedData::CsvImporter.new.import!
    puts "Seed CSVs imported."
  end
end
