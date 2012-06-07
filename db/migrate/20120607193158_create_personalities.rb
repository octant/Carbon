class CreatePersonalities < ActiveRecord::Migration
  def change
    create_table :personalities do |t|
      t.string :name
      t.string :ip
      t.integer :device_id
      t.integer :network_id

      t.timestamps
    end
  end
end
