module V1
  module Entities
    module Users
      module Show
        class User < Grape::Entity
          root 'users', 'user'

          expose :id,
                 :email,
                 :username,
                 :role,
                 :created_at,
                 :updated_at

          expose :bookings, using: Entities::Bookings::Index::Booking do |user, _options|
            user.bookings
          end

          expose :token, if: ->(_instance, options) { options[:token] } do |_instance, options|
            options[:token]
          end
        end
      end
    end
  end
end
