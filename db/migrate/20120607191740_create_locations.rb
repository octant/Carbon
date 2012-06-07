class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :address
      t.string :status, :default => 'Active'

      t.timestamps
    end
  end
end
