class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.string :name
      t.string :surname
      t.string :phone
      t.references :table, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :status

      t.timestamps
    end
  end
end
