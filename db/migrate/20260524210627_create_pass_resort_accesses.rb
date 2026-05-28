class CreatePassResortAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :pass_resort_accesses do |t|
      t.references :pass_product, foreign_key: true
      t.references :resort, foreign_key: true
      t.string :access_tier
      t.integer :access_days
      t.boolean :unlimited_access
      t.boolean :reservation_required
      t.boolean :blackout_dates_apply
      t.text :notes

      t.timestamps
    end

    add_index :pass_resort_accesses,
    [:pass_product_id, :resort_id, :access_tier],
    unique: true
  end
end
