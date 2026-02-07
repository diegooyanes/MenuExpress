class Table < ApplicationRecord
  belongs_to :restaurant
  has_many :reservations

  validates :number, presence: true
  validates :capacity, numericality: { greater_than: 0 }, presence: true

  before_validation :set_default_available

  private

  def set_default_available
    self.available = true if available.nil?
  end
end
