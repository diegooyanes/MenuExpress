module Admin
  class SubscriptionsController < ApplicationController
    before_action :authenticate_restaurant!
    before_action :set_restaurant
    before_action :authorize_restaurant!

    def new
      @plan = :monthly
      if @restaurant.subscribed?
        redirect_to admin_restaurant_path(@restaurant), notice: "Tu suscripcion ya esta activa."
      end
    end

    def create
      return redirect_to admin_restaurant_path(@restaurant), notice: "Tu suscripcion ya esta activa." if @restaurant.subscribed?

      unless Stripe.api_key.present?
        return redirect_to new_admin_restaurant_subscription_path(@restaurant),
                           alert: "Falta configurar STRIPE_SECRET_KEY."
      end

      price_id = ENV["STRIPE_PRICE_ID"]
      unless price_id.present?
        return redirect_to new_admin_restaurant_subscription_path(@restaurant),
                           alert: "Falta configurar STRIPE_PRICE_ID."
      end

      if @restaurant.stripe_customer_id.blank?
        customer = Stripe::Customer.create(email: @restaurant.email, name: @restaurant.name)
        @restaurant.update!(stripe_customer_id: customer.id)
      end

      session = Stripe::Checkout::Session.create(
        customer: @restaurant.stripe_customer_id,
        mode: "subscription",
        line_items: [{ price: price_id, quantity: 1 }],
        success_url: success_admin_restaurant_subscriptions_url(@restaurant, session_id: "{CHECKOUT_SESSION_ID}"),
        cancel_url: cancel_admin_restaurant_subscriptions_url(@restaurant)
      )

      pending = @restaurant.subscriptions.where(status: "pending").order(created_at: :desc).first
      if pending
        pending.update(checkout_session_id: session.id, stripe_price_id: price_id)
      else
        @restaurant.subscriptions.create(
          plan: params[:plan] || "monthly",
          status: "pending",
          price_cents: Subscription::PLANS[:monthly][:price_cents],
          checkout_session_id: session.id,
          stripe_price_id: price_id
        )
      end

      redirect_to session.url, allow_other_host: true
    end

    def success
      session = Stripe::Checkout::Session.retrieve(params[:session_id])
      subscription_id = session.subscription

      unless session.payment_status == "paid"
        return redirect_to new_admin_restaurant_subscription_path(@restaurant), alert: "El pago no se completó."
      end

      record = @restaurant.subscriptions.find_by(checkout_session_id: session.id) ||
               @restaurant.subscriptions.create!(
                 plan: "monthly",
                 status: "pending",
                 price_cents: Subscription::PLANS[:monthly][:price_cents],
                 checkout_session_id: session.id,
                 stripe_price_id: ENV["STRIPE_PRICE_ID"]
               )

      record.update!(
        status: "active",
        started_at: Time.current,
        stripe_subscription_id: subscription_id,
        gateway_charge_id: subscription_id
      )

      redirect_to admin_restaurant_path(@restaurant), notice: "Suscripcion activa. Bienvenido!"
    rescue Stripe::StripeError => e
      redirect_to new_admin_restaurant_subscription_path(@restaurant), alert: e.message
    end

    def cancel
      redirect_to new_admin_restaurant_subscription_path(@restaurant), alert: "Pago cancelado."
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
