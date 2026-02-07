class StripeWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def create
    payload = request.raw_post
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    webhook_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      subscription_id = session.subscription
      customer_id = session.customer

      subscription = Subscription.find_by(checkout_session_id: session.id)
      if subscription
        subscription.update(
          status: "active",
          stripe_subscription_id: subscription_id,
          gateway_charge_id: subscription_id,
          started_at: Time.current
        )
      else
        restaurant = Restaurant.find_by(stripe_customer_id: customer_id)
        if restaurant
          restaurant.subscriptions.create!(
            plan: "monthly",
            status: "active",
            price_cents: Subscription::PLANS[:monthly][:price_cents],
            started_at: Time.current,
            stripe_subscription_id: subscription_id,
            checkout_session_id: session.id,
            stripe_price_id: ENV["STRIPE_PRICE_ID"],
            gateway_charge_id: subscription_id
          )
        end
      end
    when "customer.subscription.deleted"
      subscription = event.data.object
      record = Subscription.find_by(stripe_subscription_id: subscription.id)
      record&.update(status: "cancelled")
    when "customer.subscription.updated"
      subscription = event.data.object
      record = Subscription.find_by(stripe_subscription_id: subscription.id)
      record&.update(status: subscription.status)
    end

    render json: { status: "ok" }
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    render json: { error: e.message }, status: :bad_request
  end
end
