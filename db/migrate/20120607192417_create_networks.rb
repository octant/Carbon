class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.string :network_identifier
      t.string :network_mask
      t.string :default_gateway
      t.integer :location_id

      t.timestamps
    end
  end
end
