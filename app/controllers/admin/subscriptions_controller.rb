module Admin
  class SubscriptionsController < ApplicationController
    before_action :authenticate_restaurant!
    before_action :set_restaurant
    before_action :authorize_restaurant!

    def new
      @plan = :monthly
    end

    def create
      # Simulate a successful payment and create subscription record
      @subscription = @restaurant.subscriptions.create(
        plan: params[:plan] || 'monthly',
        status: 'active',
        price_cents: Subscription::PLANS[:monthly][:price_cents],
        started_at: Time.current,
        gateway_charge_id: 'simulation_#{SecureRandom.hex(8)}'
      )

      if @subscription.persisted?
        redirect_to admin_restaurant_path(@restaurant), notice: "Pago simulado exitoso. Suscripción activa por $15/mes."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @subscription = @restaurant.subscriptions.find(params[:id])
    end

    private

    def set_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def authorize_restaurant!
      redirect_to admin_restaurants_path, alert: 'Not authorized' unless current_restaurant == @restaurant
    end
  end
end
