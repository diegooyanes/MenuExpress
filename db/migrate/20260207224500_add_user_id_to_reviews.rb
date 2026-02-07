class AddUserIdToReviews < ActiveRecord::Migration[8.1]
  def change
    add_column :reviews, :user_id, :bigint
    add_index :reviews, :user_id
    add_foreign_key :reviews, :users
  end
end
