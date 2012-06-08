class CreateVulnerabilities < ActiveRecord::Migration
  def change
    create_table :vulnerabilities do |t|
      t.string :qid
      t.string :severity
      t.string :title
      t.date :last_update
      t.text :diagnosis
      t.text :consequence
      t.text :solution
      t.boolean :pci
      t.boolean :fixable

      t.timestamps
    end
  end
end
