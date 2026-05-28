# == Schema Information
#
# Table name: pass_products
#
#  id           :bigint           not null, primary key
#  company_name :string
#  name         :string           not null
#  notes        :text
#  season       :string
#  website_url  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_pass_products_on_name_and_season  (name,season) UNIQUE
#
require "rails_helper"

RSpec.describe PassProduct, type: :model do
  describe "associations" do
    it { should have_many(:pass_resort_accesses).dependent(:destroy) }
    it { should have_many(:resorts).through(:pass_resort_accesses) }
    it { should have_many(:resort_groups).through(:pass_resort_accesses) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
