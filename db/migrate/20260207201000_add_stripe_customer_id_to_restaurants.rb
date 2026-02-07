class AddStripeCustomerIdToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :stripe_customer_id, :string
    add_index :restaurants, :stripe_customer_id
  end
end
