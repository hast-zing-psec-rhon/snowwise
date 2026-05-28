# == Schema Information
#
# Table name: resort_group_memberships
#
#  id              :bigint           not null, primary key
#  notes           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  resort_group_id :bigint           not null
#  resort_id       :bigint           not null
#
# Indexes
#
#  idx_on_resort_group_id_resort_id_a650f73668        (resort_group_id,resort_id) UNIQUE
#  index_resort_group_memberships_on_resort_group_id  (resort_group_id)
#  index_resort_group_memberships_on_resort_id        (resort_id)
#
# Foreign Keys
#
#  fk_rails_...  (resort_group_id => resort_groups.id)
#  fk_rails_...  (resort_id => resorts.id)
#
require "rails_helper"

RSpec.describe ResortGroupMembership, type: :model do
  describe "associations" do
    it { should belong_to(:resort_group) }
    it { should belong_to(:resort) }
  end
end
