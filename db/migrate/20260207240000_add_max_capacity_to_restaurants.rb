class AddMaxCapacityToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :max_capacity, :integer
    change_column_null :reservations, :table_id, true
  end
end
