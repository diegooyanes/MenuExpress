class Review < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user, optional: true

  has_one_attached :photo

  validates :name, presence: true, length: { minimum: 2, maximum: 60 }
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 500 }
end
