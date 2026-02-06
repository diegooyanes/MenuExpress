class Restaurant < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :menu_items, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many_attached :photos

  validates :name, presence: true
  validates :description, :address, presence: true, on: :update
  validates :email, uniqueness: true
  validates :open_time, :close_time, presence: true, on: :update

  def to_s
    name
  end
end
