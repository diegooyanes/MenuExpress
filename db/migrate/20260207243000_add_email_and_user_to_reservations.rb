class AddEmailAndUserToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :email, :string
    add_reference :reservations, :user, foreign_key: true
  end
end
