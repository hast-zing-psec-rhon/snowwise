class CreateResortGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :resort_groups do |t|
      t.string :name
      t.string :country
      t.string :state_or_region
      t.string :website_url
      t.text :notes

      t.timestamps
    end

    add_index :resort_groups, [:name, :country, :state_or_region], unique: true
  end
end
