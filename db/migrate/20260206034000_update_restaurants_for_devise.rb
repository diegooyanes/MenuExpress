class UpdateRestaurantsForDevise < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :email, :string, null: false, default: ""
    add_column :restaurants, :encrypted_password, :string, null: false, default: ""
    add_column :restaurants, :reset_password_token, :string
    add_column :restaurants, :reset_password_sent_at, :datetime
    add_column :restaurants, :remember_created_at, :datetime

    add_index :restaurants, :email, unique: true
    add_index :restaurants, :reset_password_token, unique: true
  end
end
