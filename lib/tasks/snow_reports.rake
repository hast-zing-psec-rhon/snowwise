require "csv"

namespace :snow_reports do
  desc "Import snow report sources from data/snow_report_sources.csv"
  task import_sources: :environment do
    path = Rails.root.join("data", "snow_report_sources.csv")
    imported_count = 0
    skipped_count = 0

    CSV.foreach(path, headers: true) do |row|
      resort = Resort.find_by(name: row.fetch("resort_name"))

      if resort.blank?
        skipped_count += 1
        puts "Skipping unknown resort: #{row.fetch("resort_name")}"
        next
      end

      source = SnowReportSource.find_or_initialize_by(
        resort: resort,
        source_url: row.fetch("snow_report_url")
      )

      source.update!(
        provider_name: row.fetch("source_type"),
        source_name: row.fetch("source_name"),
        source_type: row.fetch("source_type"),
        priority: row.fetch("data_found") == "true" ? 50 : 100,
        parser_strategy: "openai_text_extraction",
        active: true,
        notes: row["notes"]
      )

      imported_count += 1
    end

    puts "Imported #{imported_count} snow report sources."
    puts "Skipped #{skipped_count} rows."
  end

  desc "Refresh snow report for one resort. Usage: bin/rails 'snow_reports:refresh_one[Alta Ski Area]'"
  task :refresh_one, [:resort_name] => :environment do |_task, args|
    resort_name = args[:resort_name]

    if resort_name.blank?
      puts "Usage: bin/rails 'snow_reports:refresh_one[Alta Ski Area]'"
      exit 1
    end

    resort = Resort.find_by(name: resort_name)

    if resort.blank?
      puts "Could not find resort: #{resort_name}"
      exit 1
    end

    observation = SnowReports::RefreshResort.new.call(resort: resort)

    if observation.present?
      Conditions::RefreshScore.call(resort: resort)

      puts "Created snow observation for #{resort.name}"
      puts "Base depth: #{observation.base_depth_inches || "unknown"} inches"
      puts "Observed at: #{observation.observed_at}"
      puts "Source: #{observation.source_name}"
      puts "Confidence: #{observation.confidence}"
      puts "Refreshed condition score for #{resort.name}"
    else
      puts "No valid snow observation found for #{resort.name}"
    end
  end

  desc "Refresh snow reports for a small sample. Usage: bin/rails 'snow_reports:refresh_sample[5]'"
  task :refresh_sample, [:limit] => :environment do |_task, args|
    limit = args[:limit].presence&.to_i || 5
    scope = Resort.joins(:snow_report_sources).distinct.order(:name).limit(limit)

    run = SnowReports::RefreshAllResorts.new.call(scope: scope)
    refreshed_count = Conditions::RefreshAllScores.call(scope: scope)

    puts "Snow refresh sample finished with status: #{run.status}"
    puts "Resorts attempted: #{run.resorts_attempted}"
    puts "Observations created: #{run.observations_created}"
    puts "Errors: #{run.error_count}"
    puts "Refreshed #{refreshed_count} resort condition scores."
  end

  desc "Refresh snow reports for all resorts"
  task refresh_all: :environment do
    run = SnowReports::RefreshAllResorts.new.call
    refreshed_count = Conditions::RefreshAllScores.call

    puts "Snow refresh finished with status: #{run.status}"
    puts "Resorts attempted: #{run.resorts_attempted}"
    puts "Observations created: #{run.observations_created}"
    puts "Errors: #{run.error_count}"
    puts "Refreshed #{refreshed_count} resort condition scores."
  end
end
