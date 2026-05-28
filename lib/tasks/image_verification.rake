require "csv"
require "net/http"
require "uri"

namespace :images do
  desc "Verify resort image URLs return image responses"
  task verify: :environment do
    failures = []
    checked_count = 0

    CSV.read(Rails.root.join("data/resort_images.csv"), headers: true).each do |row|
      url = row["image_url"].to_s.strip
      next if url.blank?

      checked_count += 1
      response = verify_image_url(url)
      content_type = response["content-type"].to_s

      next if response.code.to_i.between?(200, 299) && content_type.start_with?("image/")

      failures << [row["resort_name"], row["image_type"], response.code, content_type, url]
    rescue StandardError => error
      failures << [row["resort_name"], row["image_type"], error.class.name, error.message, url]
    end

    puts "Checked #{checked_count} image URLs; #{failures.size} failures"
    failures.each do |failure|
      puts failure.join(" | ")
    end

    abort("Resort image verification failed") if failures.any?
  end

  def verify_image_url(url)
    uri = URI(url)

    3.times do
      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: 8,
        read_timeout: 8
      ) do |http|
        request = Net::HTTP::Head.new(uri)
        request["User-Agent"] = "Snowwise image verifier"
        http.request(request)
      end

      if response.is_a?(Net::HTTPRedirection) && response["location"].present?
        uri = URI.join(uri, response["location"])
        next
      end

      return response unless response.code.to_i == 405

      return Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: 8,
        read_timeout: 8
      ) do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "Snowwise image verifier"
        http.request(request)
      end
    end
  end
end
