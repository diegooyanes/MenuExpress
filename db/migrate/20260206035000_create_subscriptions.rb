class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :plan
      t.string :status
      t.integer :price_cents
      t.datetime :started_at
      t.string :gateway_charge_id

      t.timestamps
    end
  end
end
