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

          # camel case format
          expose :userId do |booking, _options|
            booking.user_id
          end

          expose :accommodationId do |booking, _options|
            booking.accommodation_id
          end

          expose :startDate do |booking, _options|
            booking.start_date
          end

          expose :endDate do |booking, _options|
            booking.end_date
          end

          expose :createdAt do |booking, _options|
            booking.created_at
          end

          expose :updatedAt do |booking, _options|
            booking.created_at
          end
        end
      end
    end
  end
end
