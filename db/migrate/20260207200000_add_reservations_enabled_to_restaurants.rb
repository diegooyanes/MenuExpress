class AddReservationsEnabledToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :reservations_enabled, :boolean, default: true, null: false
  end
end
