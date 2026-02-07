class ReservationMailer < ApplicationMailer
  def confirmation(reservation)
    @reservation = reservation
    @restaurant = reservation.restaurant
    mail(
      to: reservation.email,
      subject: "Reserva confirmada en #{@restaurant.name}"
    )
  end
end
