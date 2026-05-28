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
class PassResortAccess < ApplicationRecord
  belongs_to :pass_product
  belongs_to :resort, optional: true
  belongs_to :resort_group, optional: true

  validates :access_tier, presence: true
  validates :access_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validate :exactly_one_access_target

  private

  def exactly_one_access_target
    if resort.present? == resort_group.present?
      errors.add(:base, "must belong to either a resort or a resort group")
    end
  end
end
