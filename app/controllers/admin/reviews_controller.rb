module Admin
  class ReviewsController < ApplicationController
    before_action :authenticate_restaurant!
    before_action :require_active_subscription!
    before_action :set_restaurant
    before_action :authorize_restaurant!
    before_action :set_review, only: [:show, :destroy]

    def index
      @reviews = @restaurant.reviews.order(created_at: :desc)
    end

    def show
    end

    def destroy
      @review.destroy
      redirect_to admin_restaurant_reviews_path(@restaurant), notice: "Resena eliminada."
    end

    private

    def set_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def set_review
      @review = @restaurant.reviews.find(params[:id])
    end

    def authorize_restaurant!
      redirect_to admin_restaurants_path, alert: "Not authorized" unless current_restaurant == @restaurant
    end
  end
end
