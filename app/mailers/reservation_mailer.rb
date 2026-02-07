class ReservationMailer < ApplicationMailer
  def confirmation(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    @confirm_url = confirm_reservation_url(token: reservation.confirm_token)
    @cancel_url = cancel_reservation_url(token: reservation.cancel_token)
    mail(
      to: reservation.email,
      subject: "Reserva confirmada en #{@restaurant.name}"
    )
  end

  def restaurant_notification(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    @day_url = admin_restaurant_reservations_url(@restaurant, date: reservation.reservation_date)
    mail(
      to: @restaurant.email,
      subject: "Nueva reserva en #{@restaurant.name}"
    )
  end
end
