class Reservation < ApplicationRecord
  STATUSES = {
    pending: "pending",
    confirmed: "confirmed",
    completed: "completed",
    cancelled: "cancelled"
  }.freeze

  belongs_to :table, optional: true
  belongs_to :restaurant
  belongs_to :user, optional: true

  validates :first_name, :last_name, :phone_number, :number_of_guests, :email, presence: true
  validates :reservation_date, :reservation_time, presence: true
  validates :number_of_guests, numericality: { greater_than: 0 }
  validates :phone_number, format: { with: /\A[0-9\s\-\+\(\)]+\z/, message: "should contain only digits and symbols" }
  validates :status, inclusion: { in: STATUSES.values }
  validate :capacity_available_for_time

  before_validation :set_default_status

  scope :upcoming, -> { where("reservation_date >= ?", Date.current).order(:reservation_date) }
  scope :past, -> { where("reservation_date < ?", Date.current).order(reservation_date: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :completed, -> { where(status: "completed") }

  def full_name
    "#{first_name} #{last_name}"
  end

  def reserved_datetime
    return if reservation_date.blank? || reservation_time.blank?
    time_value =
      if reservation_time.is_a?(String)
        Time.zone.parse(reservation_time)
      else
        reservation_time
      end
    return if time_value.blank?

    Time.zone.local(
      reservation_date.year,
      reservation_date.month,
      reservation_date.day,
      time_value.hour,
      time_value.min
    )
  end

  def status_label
    display_status
  end

  def display_status
    return "Cancelada" if status == "cancelled"
    return "Completada" if status == "completed"
    return "Confirmado" if status == "confirmed"

    # Si no se confirmó por correo, se mantiene pendiente hasta 1 hora antes.
    return "Confirmado" if reserved_datetime.present? && reserved_datetime <= 1.hour.from_now

    "Pendiente"
  end

  def display_status_class
    return "cancelled" if display_status == "Cancelada"
    return "completed" if display_status == "Completada"
    return "confirmed" if display_status == "Confirmado"
    "pending"
  end

  def cancellable?
    return false if reserved_datetime.blank?
    reserved_datetime > 1.hour.from_now
  end

  def confirm_token
    signed_id(purpose: "reservation_confirm", expires_in: 7.days)
  end

  def cancel_token
    signed_id(purpose: "reservation_cancel", expires_in: 7.days)
  end

  private

  def set_default_status
    self.status ||= "pending"
  end

  def capacity_available_for_time
    return if reservation_date.blank? || reservation_time.blank? || number_of_guests.blank?

    capacity = restaurant&.max_capacity.to_i
    return if capacity <= 0

    reserved_guests = Reservation.where(
      restaurant_id: restaurant_id,
      reservation_date: reservation_date,
      reservation_time: reservation_time
    ).where.not(status: "cancelled")

    reserved_guests = reserved_guests.where.not(id: id) if persisted?

    total = reserved_guests.sum(:number_of_guests).to_i
    if total + number_of_guests.to_i > capacity
      errors.add(:base, "No hay cupo disponible para esa fecha y hora.")
    end
  end
end
