module SnowReports
  class ObservationValidator
    OPERATING_STATUSES = %w[
      open
      closed
      preseason
      offseason
      summer_operations
      unknown
    ].freeze

    ZERO_DEPTH_REASONS = %w[
      explicit_zero
      closed
      preseason
      offseason
      summer_operations
      no_snow
    ].freeze

    NUMERIC_FIELDS = %w[
      base_depth_inches
      mid_depth_inches
      upper_depth_inches
      new_snow_24h_inches
      new_snow_48h_inches
      new_snow_7d_inches
    ].freeze

    def call(extracted_data:)
      errors = []

      errors << "source_evidence must be present" if extracted_data["source_evidence"].blank?
      errors << "confidence must be present" if extracted_data["confidence"].blank?

      unless OPERATING_STATUSES.include?(extracted_data["operating_status"])
        errors << "operating_status is invalid"
      end

      zero_depth_reason = extracted_data["zero_depth_reason"]
      if zero_depth_reason.present? && !ZERO_DEPTH_REASONS.include?(zero_depth_reason)
        errors << "zero_depth_reason is invalid"
      end

      numeric_values = NUMERIC_FIELDS.map { |field| extracted_data[field] }.compact

      if numeric_values.empty?
        errors << "at least one snow depth or snowfall value must be present"
      end

      numeric_values.each do |value|
        if !value.is_a?(Numeric)
          errors << "numeric snow fields must be numbers or null"
        elsif value.negative?
          errors << "numeric snow fields cannot be negative"
        elsif value > 1_000
          errors << "numeric snow fields look unreasonably high"
        end
      end

      base_depth = extracted_data["base_depth_inches"]
      if base_depth == 0 && zero_depth_reason.blank?
        errors << "zero base depth requires zero_depth_reason"
      end

      if base_depth.nil? && zero_depth_reason.present?
        errors << "zero_depth_reason should only be present when base_depth_inches is 0"
      end

      Result.new(valid?: errors.empty?, errors: errors)
    end

    Result = Data.define(:valid?, :errors)
  end
end
