module V1
  module Entities
    module Bookings
      module Show
        class Booking < Grape::Entity
          root 'bookings', 'booking'

          format_with :date_format do |date|
            date.strftime('%Y-%m-%d')
          end

          expose :id,
                 :user_id,
                 :accommodation_id,
                 :start_date,
                 :end_date

          expose :created_at, :updated_at, format_with: :date_format

          expose :city, using: Entities::City do |booking, _options|
            booking.accommodation.city
          end

          expose :user, using: Entities::User do |booking, _options|
            booking.user
          end

          expose :accommodation, using: Entities::Accommodation do |booking, _options|
            booking.accommodation
          end

          expose :options, using: Entities::Option do |booking, _options|
            booking.accommodation.options
          end
        end
      end
    end
  end
end
