class Reservation < ApplicationRecord
  STATUSES = { pending: "pending", confirmed: "confirmed", cancelled: "cancelled" }.freeze

  belongs_to :table
  belongs_to :restaurant

  validates :first_name, :last_name, :phone_number, :number_of_guests, presence: true
  validates :reservation_date, :reservation_time, presence: true
  validates :number_of_guests, numericality: { greater_than: 0 }
  validates :phone_number, format: { with: /\A[0-9\s\-\+\(\)]+\z/, message: "should contain only digits and symbols" }
  validates :status, inclusion: { in: STATUSES.values }

  before_validation :set_default_status

  scope :upcoming, -> { where("reservation_date >= ?", Date.current).order(:reservation_date) }
  scope :past, -> { where("reservation_date < ?", Date.current).order(reservation_date: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }

  def full_name
    "#{first_name} #{last_name}"
  end

  def reserved_datetime
    DateTime.combine(reservation_date, reservation_time)
  end

  private

  def set_default_status
    self.status ||= "pending"
  end
end
