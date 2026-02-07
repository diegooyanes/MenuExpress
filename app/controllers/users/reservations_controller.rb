module Users
  class ReservationsController < ApplicationController
    before_action :authenticate_user!

    def index
      @reservations = current_user.reservations.order(reservation_date: :desc, reservation_time: :desc)
    end

    def destroy
      reservation = current_user.reservations.find(params[:id])
      unless reservation.cancellable?
        return redirect_to users_reservations_path, alert: "Solo puedes cancelar hasta 1 hora antes de la reserva."
      end

      reservation.update(status: "cancelled")
      redirect_to users_reservations_path, notice: "Reserva cancelada."
    end
  end
end
