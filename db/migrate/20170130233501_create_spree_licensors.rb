class CreateSpreeLicensors < ActiveRecord::Migration
  def change
    create_table :spree_licensors do |t|
      t.string :name,  null: false
      t.integer :user_id,  null: false
      t.integer :taxon_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :spree_licensors, :spree_users, column: :user_id
    add_index :spree_licensors, :user_id

    add_foreign_key :spree_licensors, :spree_taxons, column: :taxon_id
    add_index :spree_licensors, :taxon_id

    add_column :spree_licensors, :deleted_at, :timestamp
    add_index :spree_licensors, :deleted_at
  end
end
