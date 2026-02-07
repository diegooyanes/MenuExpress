class Admin::ReservationsController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :require_active_subscription!
  before_action :set_restaurant
  before_action :authorize_restaurant!
  before_action :set_reservation, only: [:show, :edit, :update]

  # GET /admin/restaurants/:restaurant_id/reservations
  def index
    @upcoming_reservations = @restaurant.reservations.upcoming.order(:reservation_date, :reservation_time)
    @past_reservations = @restaurant.reservations.past.order(reservation_date: :desc)

    base_date =
      if params[:date].present?
        Date.parse(params[:date]) rescue Date.current
      else
        Date.current
      end
    @calendar_view = params[:view] == "month" ? "month" : "week"

    if @calendar_view == "month"
      start_date = base_date.beginning_of_month.beginning_of_week(:monday)
      end_date = base_date.end_of_month.end_of_week(:monday)
      @calendar_days = (start_date..end_date).to_a
    else
      start_date = base_date.beginning_of_week(:monday)
      @calendar_days = (0..6).map { |i| start_date + i }
    end

    @calendar_view = "day" if params[:date].present?
    if @calendar_view == "day"
      @calendar_days = [base_date]
      @day_reservations = @restaurant.reservations
                                    .where(reservation_date: base_date)
                                    .order(:reservation_time)

      if params[:q].present?
        query = "%#{params[:q].strip}%"
        @day_reservations = @day_reservations.where("first_name ILIKE ? OR last_name ILIKE ?", query, query)
      end
    else
      @day_reservations = []
    end

    total_capacity = @restaurant.max_capacity.to_i
    daily_counts = @restaurant.reservations
                              .where(reservation_date: @calendar_days)
                              .where.not(status: "cancelled")
                              .group(:reservation_date)
                              .sum(:number_of_guests)
    @fully_booked_days = if total_capacity.positive?
                           daily_counts.select { |_, count| count >= total_capacity }.keys
                         else
                           []
                         end
  end

  # GET /admin/restaurants/:restaurant_id/reservations/:id
  def show
  end

  # GET /admin/restaurants/:restaurant_id/reservations/:id/edit
  def edit
    redirect_to admin_restaurant_reservation_path(@restaurant, @reservation),
                alert: "El estado de la reserva no se puede modificar desde el restaurante."
  end

  # PATCH/PUT /admin/restaurants/:restaurant_id/reservations/:id
  def update
    redirect_to admin_restaurant_reservation_path(@restaurant, @reservation),
                alert: "El estado de la reserva no se puede modificar desde el restaurante."
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
