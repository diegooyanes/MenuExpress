class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Make Devise helpers available in views
  include Devise::Controllers::Helpers

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # Redirect to login if restaurant is not authenticated (call via before_action)
  def authenticate_restaurant!
    redirect_to new_restaurant_session_path, alert: "Please sign in to your restaurant account" unless restaurant_signed_in?
  end

  def require_active_subscription!
    return unless restaurant_signed_in?
    return unless ENV["STRIPE_REQUIRED"] == "true"
    return if current_restaurant.subscribed?

    redirect_to new_admin_restaurant_subscription_path(current_restaurant),
                alert: "Activa tu suscripcion para continuar."
  end
end
