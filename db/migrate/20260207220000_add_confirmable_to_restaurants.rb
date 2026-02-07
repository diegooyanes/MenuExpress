class AddConfirmableToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :confirmation_token, :string
    add_column :restaurants, :confirmed_at, :datetime
    add_column :restaurants, :confirmation_sent_at, :datetime
    add_column :restaurants, :unconfirmed_email, :string

    add_index :restaurants, :confirmation_token, unique: true
  end
end
