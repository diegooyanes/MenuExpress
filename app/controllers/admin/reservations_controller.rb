class Admin::ReservationsController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_restaurant
  before_action :authorize_restaurant!
  before_action :set_reservation, only: [:show, :edit, :update]

  # GET /admin/restaurants/:restaurant_id/reservations
  def index
    @upcoming_reservations = @restaurant.reservations.upcoming.order(:reservation_date)
    @past_reservations = @restaurant.reservations.past.order(reservation_date: :desc)
  end

  # GET /admin/restaurants/:restaurant_id/reservations/:id
  def show
  end

  # GET /admin/restaurants/:restaurant_id/reservations/:id/edit
  def edit
  end

  # PATCH/PUT /admin/restaurants/:restaurant_id/reservations/:id
  def update
    old_status = @reservation.status

    if @reservation.update(reservation_params)
      redirect_to admin_restaurant_reservation_path(@restaurant, @reservation),
                  notice: "Reservation was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_reservation
    @reservation = @restaurant.reservations.find(params[:id])
  end

  def authorize_restaurant!
    redirect_to admin_restaurants_path, alert: "Not authorized" unless current_restaurant == @restaurant
  end

  def reservation_params
    params.require(:reservation).permit(:status)
  end
end
