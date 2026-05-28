class TightenCoreDataConstraints < ActiveRecord::Migration[8.0]
  def change
    change_column_null :pass_products, :name, false
    change_column_null :resorts, :name, false
    change_column_null :resorts, :country, false
    change_column_null :resort_groups, :name, false
    change_column_null :resort_group_memberships, :resort_group_id, false
    change_column_null :resort_group_memberships, :resort_id, false

    change_column_null :pass_resort_accesses, :pass_product_id, false
    change_column_null :pass_resort_accesses, :access_tier, false

    change_column_default :pass_resort_accesses, :unlimited_access, from: nil, to: false
    change_column_default :pass_resort_accesses, :reservation_required, from: nil, to: false
    change_column_default :pass_resort_accesses, :blackout_dates_apply, from: nil, to: false

    change_column_null :pass_resort_accesses, :unlimited_access, false
    change_column_null :pass_resort_accesses, :reservation_required, false
    change_column_null :pass_resort_accesses, :blackout_dates_apply, false
  end
end
