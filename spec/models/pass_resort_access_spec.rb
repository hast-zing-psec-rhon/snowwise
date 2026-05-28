# == Schema Information
#
# Table name: pass_resort_accesses
#
#  id                   :bigint           not null, primary key
#  access_days          :integer
#  access_tier          :string           not null
#  blackout_dates_apply :boolean          default(FALSE), not null
#  notes                :text
#  reservation_required :boolean          default(FALSE), not null
#  unlimited_access     :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  pass_product_id      :bigint           not null
#  resort_group_id      :bigint
#  resort_id            :bigint
#
# Indexes
#
#  idx_pass_access_unique_resort                  (pass_product_id,resort_id,access_tier) UNIQUE WHERE (resort_id IS NOT NULL)
#  idx_pass_access_unique_resort_group            (pass_product_id,resort_group_id,access_tier) UNIQUE WHERE (resort_group_id IS NOT NULL)
#  index_pass_resort_accesses_on_pass_product_id  (pass_product_id)
#  index_pass_resort_accesses_on_resort_group_id  (resort_group_id)
#  index_pass_resort_accesses_on_resort_id        (resort_id)
#
# Foreign Keys
#
#  fk_rails_...  (pass_product_id => pass_products.id)
#  fk_rails_...  (resort_group_id => resort_groups.id)
#  fk_rails_...  (resort_id => resorts.id)
#
require "rails_helper"

RSpec.describe PassResortAccess, type: :model do
  describe "associations" do
    it { should belong_to(:pass_product) }
    it { should belong_to(:resort).optional }
    it { should belong_to(:resort_group).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:access_tier) }

    it do
      should validate_numericality_of(:access_days)
        .only_integer
        .is_greater_than(0)
        .allow_nil
    end
  end

  describe "access target validation" do
    let(:pass_product) do
      PassProduct.create!(
        name: "Ikon Pass",
        season: "2026-2027"
      )
    end

    let(:resort) do
      Resort.create!(
        name: "Aspen Mountain",
        country: "United States"
      )
    end

    let(:resort_group) do
      ResortGroup.create!(
        name: "Aspen Snowmass"
      )
    end

    it "is valid with a resort target" do
      access = PassResortAccess.new(
        pass_product: pass_product,
        resort: resort,
        access_tier: "full_pass",
        unlimited_access: true,
        reservation_required: false,
        blackout_dates_apply: false
      )

      expect(access).to be_valid
    end

    it "is valid with a resort group target" do
      access = PassResortAccess.new(
        pass_product: pass_product,
        resort_group: resort_group,
        access_tier: "full_pass",
        access_days: 7,
        unlimited_access: false,
        reservation_required: false,
        blackout_dates_apply: false
      )

      expect(access).to be_valid
    end

    it "is invalid with both a resort and resort group target" do
      access = PassResortAccess.new(
        pass_product: pass_product,
        resort: resort,
        resort_group: resort_group,
        access_tier: "full_pass",
        unlimited_access: false,
        reservation_required: false,
        blackout_dates_apply: false
      )

      expect(access).to be_invalid
      expect(access.errors[:base]).to include("must belong to either a resort or a resort group")
    end

    it "is invalid without a resort or resort group target" do
      access = PassResortAccess.new(
        pass_product: pass_product,
        access_tier: "full_pass",
        unlimited_access: false,
        reservation_required: false,
        blackout_dates_apply: false
      )

      expect(access).to be_invalid
      expect(access.errors[:base]).to include("must belong to either a resort or a resort group")
    end
  end
end
