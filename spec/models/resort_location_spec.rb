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
require "rails_helper"

RSpec.describe ResortLocation, type: :model do
  describe "associations" do
    it { should belong_to(:resort) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location_type) }
    it { should validate_inclusion_of(:location_type).in_array(ResortLocation::LOCATION_TYPES) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_inclusion_of(:is_primary).in_array([true, false]) }
  end
end
