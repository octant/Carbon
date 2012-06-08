class CreatePersonalityLastSeenColumn < ActiveRecord::Migration
  def change
    add_column :personalities, :last_seen, :date
  end
end
