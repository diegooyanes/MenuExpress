class UpdateReservationsTable < ActiveRecord::Migration[8.1]
  def change
    rename_column :reservations, :name, :first_name
    rename_column :reservations, :surname, :last_name
    rename_column :reservations, :phone, :phone_number

    add_column :reservations, :number_of_guests, :integer, null: false, default: 1
    add_column :reservations, :reservation_date, :date
    add_column :reservations, :reservation_time, :time

    # These columns might be used differently now, but keeping for backwards compatibility
    # You may want to drop start_time and end_time later
    add_index :reservations, [:reservation_date, :restaurant_id]
    add_index :reservations, :status
  end
end
