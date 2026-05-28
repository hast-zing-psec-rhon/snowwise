require "csv"

module SeedData
  class CsvImporter
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

    def initialize(data_path: Rails.root.join("data"))
      @data_path = data_path
      @errors = []
    end

    attr_reader :errors

    def valid?
      validate
      errors.empty?
    end

    def validate!
      validate
      raise errors.join("\n") if errors.any?
    end

    def validate
      errors.clear

      validate_resorts
      validate_resort_locations
      validate_resort_images
      validate_resort_groups
      validate_resort_group_memberships
      validate_pass_resort_accesses

      errors
    end

    def import!
      validate!

      import_pass_products
      import_resorts
      import_resort_locations
      import_resort_images
      import_resort_groups
      import_resort_group_memberships
      import_pass_resort_accesses
    end

    private

    attr_reader :data_path

    def csv(filename)
      CSV.read(data_path.join(filename), headers: true)
    end

    def add_error(message)
      errors << message
    end

    def blank_to_nil(value)
      value.presence
    end

    def csv_boolean(value)
      case value.to_s.strip.downcase
      when "true" then true
      when "false" then false
      else
        raise ArgumentError, "Expected true or false, got #{value.inspect}"
      end
    end

    def notes_with_source(notes, source_url)
      [blank_to_nil(notes), source_url.present? ? "Source: #{source_url}" : nil].compact.join("\n\n")
    end

    def validate_resorts
      csv("resorts.csv").each.with_index(2) do |row, line|
        add_error("resorts.csv line #{line}: name must be present") if blank_to_nil(row["name"]).blank?
        add_error("resorts.csv line #{line}: country must be present") if blank_to_nil(row["country"]).blank?
      end
    end

    def validate_resort_groups
      csv("resort_groups.csv").each.with_index(2) do |row, line|
        add_error("resort_groups.csv line #{line}: name must be present") if blank_to_nil(row["name"]).blank?
      end
    end

    def validate_resort_locations
      resort_names = csv("resorts.csv").map { |row| row["name"] }
      locations = csv("resort_locations.csv")

      locations.each.with_index(2) do |row, line|
        resort_name = blank_to_nil(row["resort_name"])

        if resort_name.blank?
          add_error("resort_locations.csv line #{line}: resort_name must be present")
        elsif !resort_names.include?(resort_name)
          add_error("resort_locations.csv line #{line}: unknown resort_name #{resort_name.inspect}")
        end

        add_error("resort_locations.csv line #{line}: name must be present") if blank_to_nil(row["name"]).blank?

        location_type = blank_to_nil(row["location_type"])
        if location_type.blank?
          add_error("resort_locations.csv line #{line}: location_type must be present")
        elsif !LOCATION_TYPES.include?(location_type)
          add_error("resort_locations.csv line #{line}: invalid location_type #{location_type.inspect}")
        end

        %w[latitude longitude].each do |field|
          value = blank_to_nil(row[field])
          if value.blank?
            add_error("resort_locations.csv line #{line}: #{field} must be present")
          elsif !value.match?(/\A-?\d+(\.\d+)?\z/)
            add_error("resort_locations.csv line #{line}: #{field} must be a decimal")
          end
        end

        elevation_feet = blank_to_nil(row["elevation_feet"])
        if elevation_feet.present? && !elevation_feet.match?(/\A\d+\z/)
          add_error("resort_locations.csv line #{line}: elevation_feet must be blank or a positive integer")
        end

        unless %w[true false].include?(row["is_primary"].to_s.strip.downcase)
          add_error("resort_locations.csv line #{line}: is_primary must be true or false")
        end
      end

      missing_resorts = resort_names - locations.map { |row| row["resort_name"] }
      missing_resorts.each do |resort_name|
        add_error("resort_locations.csv: missing location for resort #{resort_name.inspect}")
      end

      locations.group_by { |row| row["resort_name"] }.each do |resort_name, rows|
        next if resort_name.blank?

        primary_count = rows.count { |row| row["is_primary"].to_s.strip.downcase == "true" }
        unless primary_count == 1
          add_error("resort_locations.csv: #{resort_name.inspect} must have exactly one primary location, found #{primary_count}")
        end
      end
    end

    def validate_resort_images
      resort_names = csv("resorts.csv").map { |row| row["name"] }

      csv("resort_images.csv").each.with_index(2) do |row, line|
        resort_name = blank_to_nil(row["resort_name"])

        if resort_name.blank?
          add_error("resort_images.csv line #{line}: resort_name must be present")
        elsif !resort_names.include?(resort_name)
          add_error("resort_images.csv line #{line}: unknown resort_name #{resort_name.inspect}")
        end

        next if row["image_type"].in?(%w[logo mountain_photo unavailable])

        add_error("resort_images.csv line #{line}: image_type must be logo, mountain_photo, or unavailable")
      end
    end

    def validate_resort_group_memberships
      resort_names = csv("resorts.csv").map { |row| row["name"] }
      group_names = csv("resort_groups.csv").map { |row| row["name"] }

      csv("resort_group_memberships.csv").each.with_index(2) do |row, line|
        unless group_names.include?(row["resort_group_name"])
          add_error("resort_group_memberships.csv line #{line}: unknown resort_group_name #{row['resort_group_name'].inspect}")
        end

        unless resort_names.include?(row["resort_name"])
          add_error("resort_group_memberships.csv line #{line}: unknown resort_name #{row['resort_name'].inspect}")
        end
      end
    end

    def validate_pass_resort_accesses
      resort_names = csv("resorts.csv").map { |row| row["name"] }
      group_names = csv("resort_groups.csv").map { |row| row["name"] }

      csv("pass_resort_accesses.csv").each.with_index(2) do |row, line|
        resort_name = blank_to_nil(row["resort_name"])
        resort_group_name = blank_to_nil(row["resort_group_name"])

        if resort_name.present? == resort_group_name.present?
          add_error("pass_resort_accesses.csv line #{line}: exactly one of resort_name or resort_group_name must be present")
        end

        if resort_name.present? && !resort_names.include?(resort_name)
          add_error("pass_resort_accesses.csv line #{line}: unknown resort_name #{resort_name.inspect}")
        end

        if resort_group_name.present? && !group_names.include?(resort_group_name)
          add_error("pass_resort_accesses.csv line #{line}: unknown resort_group_name #{resort_group_name.inspect}")
        end

        %w[unlimited_access reservation_required blackout_dates_apply].each do |field|
          unless %w[true false].include?(row[field].to_s.strip.downcase)
            add_error("pass_resort_accesses.csv line #{line}: #{field} must be true or false")
          end
        end

        access_days = blank_to_nil(row["access_days"])
        if access_days.present? && !access_days.match?(/\A[1-9]\d*\z/)
          add_error("pass_resort_accesses.csv line #{line}: access_days must be blank or a positive integer")
        end
      end
    end

    def import_pass_products
      pass_products = [
        {
          name: "Ikon Pass",
          company_name: "Alterra Mountain Company",
          season: "2026-2027",
          website_url: "https://www.ikonpass.com",
          notes: "Ikon Pass"
        },
        {
          name: "Epic Pass",
          company_name: "Vail Resorts",
          season: "2026-2027",
          website_url: "https://www.epicpass.com",
          notes: "Epic Pass"
        }
      ]

      pass_products.each do |attributes|
        pass_product = PassProduct.find_or_initialize_by(
          name: attributes[:name],
          season: attributes[:season]
        )
        pass_product.update!(attributes)
      end
    end

    def import_resorts
      csv("resorts.csv").each do |row|
        resort = Resort.find_or_initialize_by(
          name: row.fetch("name"),
          country: row.fetch("country"),
          state_or_region: blank_to_nil(row["state_or_region"])
        )

        resort.update!(
          city: blank_to_nil(row["city"]),
          latitude: blank_to_nil(row["latitude"]),
          longitude: blank_to_nil(row["longitude"]),
          website_url: blank_to_nil(row["website_url"]),
          notes: blank_to_nil(row["notes"])
        )
      end
    end

    def import_resort_locations
      csv("resort_locations.csv").each do |row|
        resort = Resort.find_by!(name: row.fetch("resort_name"))

        location = ResortLocation.find_or_initialize_by(
          resort: resort,
          name: row.fetch("name")
        )

        location.update!(
          location_type: row.fetch("location_type"),
          latitude: row.fetch("latitude"),
          longitude: row.fetch("longitude"),
          elevation_feet: blank_to_nil(row["elevation_feet"]),
          is_primary: csv_boolean(row.fetch("is_primary")),
          notes: blank_to_nil(row["notes"]),
          source_url: blank_to_nil(row["source_url"])
        )
      end
    end

    def import_resort_images
      csv("resort_images.csv").each do |row|
        resort = Resort.find_by!(name: row.fetch("resort_name"))

        resort.update!(
          image_url: blank_to_nil(row["image_url"]),
          image_type: blank_to_nil(row["image_type"]),
          image_credit: blank_to_nil(row["image_credit"]),
          image_source_url: blank_to_nil(row["image_source_url"])
        )
      end
    end

    def import_resort_groups
      csv("resort_groups.csv").each do |row|
        resort_group = ResortGroup.find_or_initialize_by(
          name: row.fetch("name"),
          country: blank_to_nil(row["country"]),
          state_or_region: blank_to_nil(row["state_or_region"])
        )

        resort_group.update!(
          website_url: blank_to_nil(row["website_url"]),
          notes: blank_to_nil(row["notes"])
        )
      end
    end

    def import_resort_group_memberships
      csv("resort_group_memberships.csv").each do |row|
        resort_group = ResortGroup.find_by!(name: row.fetch("resort_group_name"))
        resort = Resort.find_by!(name: row.fetch("resort_name"))

        membership = ResortGroupMembership.find_or_initialize_by(
          resort_group: resort_group,
          resort: resort
        )

        membership.update!(notes: blank_to_nil(row["notes"]))
      end
    end

    def import_pass_resort_accesses
      csv("pass_resort_accesses.csv").each do |row|
        pass_product = PassProduct.find_by!(
          name: row.fetch("pass_product_name"),
          season: row.fetch("pass_product_season")
        )

        resort_name = blank_to_nil(row["resort_name"])
        resort_group_name = blank_to_nil(row["resort_group_name"])
        resort = resort_name.present? ? Resort.find_by!(name: resort_name) : nil
        resort_group = resort_group_name.present? ? ResortGroup.find_by!(name: resort_group_name) : nil

        access = PassResortAccess.find_or_initialize_by(
          pass_product_id: pass_product.id,
          resort_id: resort&.id,
          resort_group_id: resort_group&.id,
          access_tier: row.fetch("access_tier")
        )

        access.update!(
          access_days: blank_to_nil(row["access_days"]),
          unlimited_access: csv_boolean(row.fetch("unlimited_access")),
          reservation_required: csv_boolean(row.fetch("reservation_required")),
          blackout_dates_apply: csv_boolean(row.fetch("blackout_dates_apply")),
          notes: notes_with_source(row["notes"], row["source_url"])
        )
      end
    end
  end
end
