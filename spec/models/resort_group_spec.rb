# == Schema Information
#
# Table name: resort_groups
#
#  id              :bigint           not null, primary key
#  country         :string
#  name            :string           not null
#  notes           :text
#  state_or_region :string
#  website_url     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_resort_groups_on_name_and_country_and_state_or_region  (name,country,state_or_region) UNIQUE
#
require "rails_helper"

  RSpec.describe ResortGroup, type: :model do
    describe "associations" do
      it { should have_many(:resort_group_memberships).dependent(:destroy) }
      it { should have_many(:resorts).through(:resort_group_memberships) }
      it { should have_many(:pass_resort_accesses).dependent(:destroy) }
    end

    describe "validations" do
      it { should validate_presence_of(:name) }
    end
  end
