class CreatePurchaseRecords < ActiveRecord::Migration
  def change
    create_table :purchase_records do |t|
      t.text :description
      t.date :purchased, :default => Time.now

      t.timestamps
    end
  end
end
