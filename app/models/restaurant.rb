class Restaurant < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :menu_items, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many_attached :photos
  has_one_attached :cover_image
  has_one_attached :menu_file

  validates :name, presence: true
  validates :description, :address, presence: true, on: :update
  validates :email, uniqueness: true
  validates :open_time, :close_time, presence: true, on: :update
  validates :phone_number, format: { with: /\A[0-9\s\-\+\(\)]+\z/ }, allow_blank: true
  validates :max_capacity, numericality: { greater_than: 0, allow_nil: true }

  def to_s
    name
  end

  def average_rating
    return 0 if reviews.empty?
    reviews.average(:rating).to_f.round(1)
  end

  def active_subscription
    subscriptions.active.order(created_at: :desc).first
  end

  def subscribed?
    active_subscription.present?
  end

  def available_capacity_for(date, time, guests)
    return if guests.to_i <= 0 || date.blank? || time.blank?

    time_value =
      if time.is_a?(String)
        Time.zone.parse("#{date} #{time}") rescue nil
      else
        time
      end

    return if time_value.blank?
    return if max_capacity.to_i <= 0

    reserved_guests = reservations
                      .where(reservation_date: date, reservation_time: time_value)
                      .where.not(status: "cancelled")
                      .sum(:number_of_guests)

    (reserved_guests + guests.to_i) <= max_capacity.to_i
  end

  def available_time_slots(date, guests, interval_minutes: 30)
    return [] unless open_time && close_time
    return [] if max_capacity.to_i <= 0

    start_time = Time.zone.parse("#{date} #{open_time.strftime('%H:%M')}") rescue nil
    end_time = Time.zone.parse("#{date} #{close_time.strftime('%H:%M')}") rescue nil
    return [] if start_time.blank? || end_time.blank? || start_time >= end_time

    slots = []
    cursor = start_time
    while cursor <= end_time - interval_minutes.minutes
      slots << cursor
      cursor += interval_minutes.minutes
    end

    slots.select { |slot| available_capacity_for(date, slot, guests) }
  end
end
