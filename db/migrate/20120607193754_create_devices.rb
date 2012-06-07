class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :kind
      t.string :manufacturer
      t.string :model
      t.string :serial_number
      t.string :asset_tag
      t.string :status, :default => 'Active'
      t.integer :purchase_record_id

      t.timestamps
    end
  end
end
