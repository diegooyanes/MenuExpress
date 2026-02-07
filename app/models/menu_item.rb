class MenuItem < ApplicationRecord
  belongs_to :restaurant

  validates :name, presence: true, length: { minimum: 2, maximum: 80 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :description, length: { maximum: 300 }, allow_blank: true
  validates :category, length: { maximum: 60 }, allow_blank: true
end
