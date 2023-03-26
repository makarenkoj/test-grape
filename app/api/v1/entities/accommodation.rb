module V1
  module Entities
    class Accommodation < Grape::Entity
      root 'accommodations', 'accommodation'

      expose :id,
             :user_id,
             :city_id,
             :title,
             :type,
             :phone_number,
             :address,
             :price,
             :room,
             :created_at,
             :updated_at

      expose :city, using: Entities::City do |accommodation, _options|
        accommodation.city
      end

      expose :user, using: Entities::User do |accommodation, _options|
        accommodation.user
      end

      expose :options, using: Entities::Option do |accommodation, _options|
        accommodation.options
      end
    end
  end
end
