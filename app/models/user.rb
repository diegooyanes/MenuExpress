class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :reservations, dependent: :nullify

  validates :name, presence: true, length: { minimum: 2, maximum: 60 }
end
