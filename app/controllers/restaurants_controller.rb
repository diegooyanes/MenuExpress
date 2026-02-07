class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:show]
  before_action :require_account_for_show, only: [:show]

  # Public action - no authentication needed
  def index
    @restaurants = Restaurant.all
    if restaurant_signed_in?
      @restaurants = Restaurant.where(id: current_restaurant.id)
      @upcoming_reservations = current_restaurant.reservations.upcoming
                                                     .order(:reservation_date, :reservation_time)
    end
    if params[:search].present?
      @restaurants = @restaurants.where("name ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  # Public action - no authentication needed
  def show
    @menu_items = @restaurant.menu_items
    @reviews = @restaurant.reviews.order(created_at: :desc)
    @reservation = Reservation.new
    @selected_date = Date.current
    @guest_count = 2
    @available_times = @restaurant.available_time_slots(@selected_date, @guest_count)
    @review = Review.new
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def require_account_for_show
    return if user_signed_in? || restaurant_signed_in?

    redirect_to new_user_session_path, alert: "Inicia sesion o crea una cuenta para ver este restaurante."
  end
end
