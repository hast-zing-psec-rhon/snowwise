module SnowReports
  class RefreshResort
    def initialize(
      source_fetcher: SourceFetcher.new,
      text_extractor: HtmlTextExtractor.new,
      openai_extractor: OpenAiExtractor.new,
      observation_validator: ObservationValidator.new
    )
      @source_fetcher = source_fetcher
      @text_extractor = text_extractor
      @openai_extractor = openai_extractor
      @observation_validator = observation_validator
    end

    def call(resort:)
      resort
        .snow_report_sources
        .where(active: true)
        .order(:priority, :source_name)
        .each do |source|
          fetch = @source_fetcher.call(snow_report_source: source)

          next if fetch.raw_text.blank?

          source_text = @text_extractor.call(raw_text: fetch.raw_text)

          extracted_data = @openai_extractor.call(
            resort_name: resort.name,
            source_name: source.source_name,
            source_url: source.source_url,
            source_type: source.source_type,
            queried_at: fetch.fetched_at.iso8601,
            source_text: source_text
          )

          validation = @observation_validator.call(extracted_data: extracted_data)

          next unless validation.valid?

          return create_observation!(
            resort: resort,
            source: source,
            fetch: fetch,
            extracted_data: extracted_data
          )
        rescue StandardError => error
          Rails.logger.warn(
            "Snow refresh failed for #{resort.name} from #{source.source_name}: #{error.class} #{error.message}"
          )

          next
        end

      nil
    end

    private

    def create_observation!(resort:, source:, fetch:, extracted_data:)
      observed_at = parse_time(extracted_data["observed_at"]) || fetch.fetched_at

      observation = SnowObservation.find_or_initialize_by(
        resort: resort,
        snow_report_source: source,
        observed_at: observed_at
      )

      observation.update!(
        resort_location: nil,
        queried_at: fetch.fetched_at,
        base_depth_inches: extracted_data["base_depth_inches"],
        mid_depth_inches: extracted_data["mid_depth_inches"],
        upper_depth_inches: extracted_data["upper_depth_inches"],
        new_snow_24h_inches: extracted_data["new_snow_24h_inches"],
        new_snow_48h_inches: extracted_data["new_snow_48h_inches"],
        new_snow_7d_inches: extracted_data["new_snow_7d_inches"],
        operating_status: extracted_data["operating_status"],
        zero_depth_reason: extracted_data["zero_depth_reason"],
        surface_condition: extracted_data["surface_condition"],
        source_name: source.source_name,
        source_url: source.source_url,
        extraction_method: "openai",
        confidence: extracted_data["confidence"],
        source_evidence: extracted_data["source_evidence"],
        notes: "Fetched from #{source.source_url}"
      )

      observation
    end

    def parse_time(value)
      return nil if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
