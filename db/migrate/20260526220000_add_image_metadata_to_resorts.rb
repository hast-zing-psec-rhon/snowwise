class AddImageMetadataToResorts < ActiveRecord::Migration[8.0]
  def change
    add_column :resorts, :image_url, :string
    add_column :resorts, :image_type, :string
    add_column :resorts, :image_credit, :string
    add_column :resorts, :image_source_url, :string
  end
end
