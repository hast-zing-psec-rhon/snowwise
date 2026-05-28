class CreatePassProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :pass_products do |t|
      t.string :name
      t.string :company_name
      t.string :season
      t.string :website_url
      t.text :notes

      t.timestamps
    end
  
    add_index :pass_products, [:name, :season], unique: true
  end
end
