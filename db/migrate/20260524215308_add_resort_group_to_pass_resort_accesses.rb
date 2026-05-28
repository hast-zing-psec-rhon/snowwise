class AddResortGroupToPassResortAccesses < ActiveRecord::Migration[8.0]
  def change
    add_reference :pass_resort_accesses, :resort_group, foreign_key: true

    remove_index :pass_resort_accesses,
      column: [:pass_product_id, :resort_id, :access_tier]

    add_index :pass_resort_accesses,
      [:pass_product_id, :resort_id, :access_tier],
      unique: true,
      where: "resort_id IS NOT NULL",
      name: "idx_pass_access_unique_resort"
    
    add_index :pass_resort_accesses,
      [:pass_product_id, :resort_group_id, :access_tier],
      unique: true,
      where: "resort_group_id IS NOT NULL",
      name: "idx_pass_access_unique_resort_group"
    
    add_check_constraint :pass_resort_accesses,
      "(resort_id IS NOT NULL AND resort_group_id IS NULL) OR (resort_id IS NULL AND resort_group_id IS NOT NULL)",
      name: "pass_access_exactly_one_target"
  end
end
