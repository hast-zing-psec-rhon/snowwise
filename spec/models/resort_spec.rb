# == Schema Information
#
# Table name: resorts
#
#  id               :bigint           not null, primary key
#  city             :string
#  country          :string           not null
#  image_credit     :string
#  image_source_url :string
#  image_type       :string
#  image_url        :string
#  latitude         :decimal(, )
#  longitude        :decimal(, )
#  name             :string           not null
#  notes            :text
#  state_or_region  :string
#  website_url      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_resorts_on_name_and_country_and_state_or_region  (name,country,state_or_region) UNIQUE
#
require "rails_helper"

RSpec.describe Resort, type: :model do
  describe "associations" do
    it { should have_many(:resort_group_memberships).dependent(:destroy) }
    it { should have_many(:resort_groups).through(:resort_group_memberships) }
    it { should have_many(:pass_resort_accesses).dependent(:destroy) }
    it { should have_many(:resort_locations).dependent(:destroy) }
    it { should have_one(:primary_location).class_name("ResortLocation") }
    it { should have_one(:resort_condition_score).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:country) }
  end
end
