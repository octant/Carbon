class CreateListsPersonalitiesJoinTable < ActiveRecord::Migration
  def change
    create_table :lists_personalities, :id => false do |t|
      t.integer :list_id
      t.integer :personality_id
    end
    
    add_index :lists_personalities, [:list_id, :personality_id]
  end
end
