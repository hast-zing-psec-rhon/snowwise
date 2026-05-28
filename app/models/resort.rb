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
class Resort < ApplicationRecord
  has_many :resort_group_memberships, dependent: :destroy
  has_many :resort_groups, through: :resort_group_memberships
  has_many :resort_locations, dependent: :destroy
  has_many :pass_resort_accesses, dependent: :destroy
  has_many :snow_report_sources, dependent: :destroy
  has_many :snow_observations, dependent: :destroy
  has_one :resort_condition_score, dependent: :destroy

  has_one :latest_snow_observation,
    -> { order(observed_at: :desc, queried_at: :desc) },
    class_name: "SnowObservation"

  has_one :primary_location,
    -> { where(is_primary: true) },
    class_name: "ResortLocation"

  validates :name, presence: true
  validates :country, presence: true
  validates :image_type, inclusion: { in: %w[logo mountain_photo unavailable] }, allow_blank: true

  def pass_accesses
    PassResortAccess
      .includes(:pass_product, :resort_group)
      .where(resort: self)
      .or(
        PassResortAccess
          .includes(:pass_product, :resort_group)
          .where(resort_group: resort_groups)
      )
  end
end
