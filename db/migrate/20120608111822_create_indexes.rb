class CreateIndexes < ActiveRecord::Migration
  def change
    add_index :networks, :location_id
    add_index :personalities, [:device_id, :network_id]
    add_index :devices, :purchase_record_id
    add_index :personalities_vulnerabilities, [:personality_id, :vulnerability_id], :name => 'index_personalities_vulnerabilities'
  end
  
end
