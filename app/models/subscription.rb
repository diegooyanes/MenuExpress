class Subscription < ApplicationRecord
  belongs_to :restaurant

  PLANS = {
    monthly: { price_cents: 1500, interval: 'month' }
  }

  validates :plan, :status, presence: true

  scope :active, -> { where(status: "active") }

  def price
    price_cents.to_f / 100.0
  end

  def active?
    status == "active"
  end
end
