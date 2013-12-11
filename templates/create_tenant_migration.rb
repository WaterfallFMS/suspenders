class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :uuid, :null => false  # cross app unique key
      t.string :name, :null => false

      t.timestamps
    end

    add_index :tenants, :uuid, :unique => true
  end
end
