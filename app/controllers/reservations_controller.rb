class ReservationsController < ApplicationController
  before_action :set_restaurant, only: [:new, :create, :index]

  # GET /restaurants/:restaurant_id/reservations/new
  # Public form to make a reservation
  def new
    @reservation = @restaurant.reservations.build
  end

  # POST /restaurants/:restaurant_id/reservations
  # Create a new reservation (public, no authentication)
  def create
    @reservation = @restaurant.reservations.build(reservation_params)
    @reservation.table_id = find_available_table.id if find_available_table

    if @reservation.save
      redirect_to restaurant_path(@restaurant),
                  notice: "Reservation was successfully created. We'll confirm it soon!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/reservations
  # List reservations for a specific restaurant (public view)
  def index
    @reservations = @restaurant.reservations.order(:reservation_date)
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def reservation_params
    params.require(:reservation).permit(
      :first_name, :last_name, :phone_number,
      :number_of_guests, :reservation_date, :reservation_time
    )
  end

  def find_available_table
    @restaurant.tables.find_by("capacity >= ?", reservation_params[:number_of_guests].to_i)
  end
end
