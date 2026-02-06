class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:show]

  # Public action - no authentication needed
  def index
    @restaurants = Restaurant.all
    if params[:search].present?
      @restaurants = @restaurants.where("name ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  # Public action - no authentication needed
  def show
    @menu_items = @restaurant.menu_items
    @reviews = @restaurant.reviews.order(created_at: :desc)
    @reservation = Reservation.new
    @review = Review.new
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end
end
