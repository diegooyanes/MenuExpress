class CreateTables < ActiveRecord::Migration[8.1]
  def change
    create_table :tables do |t|
      t.integer :number
      t.integer :capacity
      t.boolean :available
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
