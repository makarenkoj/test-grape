class BookingsService
  def self.call(accommodation_id: nil, user_id: nil)
    bookings = Booking.distinct.joins('LEFT JOIN accommodations ON accommodations.id = bookings.accommodation_id
                   LEFT JOIN users ON users.id = bookings.user_id').all

    bookings = bookings.where('users.id = :user_id', user_id: user_id) if user_id.present?
    bookings = bookings.where('accommodations.id = :accommodation_id', accommodation_id: accommodation_id) if accommodation_id.present?

    bookings.order('start_date')
  end
end
