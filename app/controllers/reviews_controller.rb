class ReviewsController < ApplicationController
  before_action :set_restaurant, only: [:new, :create, :index, :destroy]
  before_action :set_review, only: [:destroy]

  def new
    @review = Review.new
  end

  def create
    @review = @restaurant.reviews.new(review_params)
    if user_signed_in?
      @review.user = current_user
      @review.name = current_user.name
    end
    if @review.save
      redirect_to restaurant_path(@restaurant), notice: "Reseña enviada con éxito"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @reviews = @restaurant.reviews
  end

  def destroy
    unless user_signed_in? && @review.user_id == current_user.id
      return redirect_to restaurant_path(@restaurant), alert: "Solo puedes eliminar tus propias reseñas."
    end

    @review.destroy
    redirect_to restaurant_path(@restaurant), notice: "Reseña eliminada."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_review
    @review = @restaurant.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:name, :rating, :comment, :photo)
  end
end
