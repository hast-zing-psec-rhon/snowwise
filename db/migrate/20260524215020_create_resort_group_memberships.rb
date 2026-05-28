class CreateResortGroupMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :resort_group_memberships do |t|
      t.references :resort_group, foreign_key: true
      t.references :resort, foreign_key: true
      t.text :notes

      t.timestamps
    end

    add_index :resort_group_memberships,
    [:resort_group_id, :resort_id],
    unique: true
  end
end
