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
class PassProduct < ApplicationRecord
  has_many :pass_resort_accesses, dependent: :destroy
  has_many :resorts, through: :pass_resort_accesses
  has_many :resort_groups, through: :pass_resort_accesses

  validates :name, presence: true
end
