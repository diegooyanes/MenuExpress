class ReservationsController < ApplicationController
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :invalid_reservation_link

  before_action :set_restaurant, only: [:new, :create, :index]

  # GET /restaurants/:restaurant_id/reservations/new
  # Public form to make a reservation
  def new
    unless @restaurant.reservations_enabled?
      return redirect_to restaurant_path(@restaurant), alert: "Reservas no disponibles en este momento."
    end

    @reservation = @restaurant.reservations.build(reservation_params_optional)
    set_availability_context
  end

  # POST /restaurants/:restaurant_id/reservations
  # Create a new reservation (public, no authentication)
  def create
    unless @restaurant.reservations_enabled?
      return redirect_to restaurant_path(@restaurant), alert: "Reservas no disponibles en este momento."
    end

    @reservation = @restaurant.reservations.build(normalized_reservation_params)
    if user_signed_in?
      @reservation.user = current_user
      @reservation.email ||= current_user.email
    end
    set_availability_context
    unless capacity_available?(@selected_date, @selected_time, @guest_count)
      @reservation.errors.add(:base, "La hora está completa. Elige otra disponible.")
      return render :new, status: :unprocessable_entity
    end

    if @reservation.save
      ReservationMailer.confirmation(@reservation).deliver_now
      ReservationMailer.restaurant_notification(@reservation).deliver_now
      redirect_to restaurant_path(@restaurant),
                  notice: "Su reserva ha sido confirmada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    reservation = Reservation.find_signed!(params[:token], purpose: "reservation_confirm")
    reservation.update(status: "confirmed") unless reservation.status == "cancelled"
    redirect_to restaurant_path(reservation.restaurant), notice: "Reserva confirmada."
  end

  def cancel
    reservation = Reservation.find_signed!(params[:token], purpose: "reservation_cancel")
    unless reservation.cancellable?
      return redirect_to restaurant_path(reservation.restaurant),
                         alert: "No puedes cancelar con menos de 1 hora de antelación."
    end

    reservation.update(status: "cancelled")
    redirect_to restaurant_path(reservation.restaurant), notice: "Reserva cancelada."
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
      :first_name, :last_name, :phone_number, :email,
      :number_of_guests, :reservation_date, :reservation_time
    )
  end

  def reservation_params_optional
    params.fetch(:reservation, {}).permit(
      :first_name, :last_name, :phone_number, :email,
      :number_of_guests, :reservation_date, :reservation_time
    )
  end

  def set_availability_context
    date_value = reservation_params_optional[:reservation_date].presence
    @selected_date = parse_date_input(date_value)
    @guest_count = reservation_params_optional[:number_of_guests].to_i
    @guest_count = 2 if @guest_count <= 0
    @available_times = @restaurant.available_time_slots(@selected_date, @guest_count)
    @selected_time = reservation_params_optional[:reservation_time]
  end

  def capacity_available?(date, time, guests)
    @restaurant.available_capacity_for(date, time, guests)
  end

  def parse_date_input(value)
    return Date.current if value.blank?

    if value.to_s.include?("/")
      Date.strptime(value, "%d/%m/%Y")
    else
      Date.parse(value)
    end
  rescue ArgumentError
    Date.current
  end

  def normalized_reservation_params
    raw = reservation_params.to_h
    raw_date = raw["reservation_date"].presence
    raw["reservation_date"] = parse_date_input(raw_date) if raw_date
    raw
  end

  def invalid_reservation_link
    redirect_to root_path, alert: "El enlace de la reserva no es válido o ha expirado."
  end
end
