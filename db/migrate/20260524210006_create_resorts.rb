class CreateResorts < ActiveRecord::Migration[8.0]
  def change
    create_table :resorts do |t|
      t.string :name
      t.string :country
      t.string :state_or_region
      t.string :city
      t.decimal :latitude
      t.decimal :longitude
      t.string :website_url
      t.text :notes

      t.timestamps
    end

    add_index :resorts, [:name, :country, :state_or_region], unique: true
  end
end
