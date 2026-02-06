class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.time :open_time
      t.time :close_time
      t.text :description
      t.string :logo

      t.timestamps
    end
  end
end
