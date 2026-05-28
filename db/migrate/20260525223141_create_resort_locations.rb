class CreateResortLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :resort_locations do |t|
      t.references :resort, null: false, foreign_key: true
      t.string :name, null: false
      t.string :location_type, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.integer :elevation_feet
      t.boolean :is_primary, null: false, default: false
      t.text :notes
      t.string :source_url

      t.timestamps
    end

    add_index :resort_locations, [:resort_id, :name], unique: true
    add_index :resort_locations,
      :resort_id,
      unique: true,
      where: "is_primary = TRUE",
      name: "idx_resort_locations_one_primary_per_resort"
  end
end
