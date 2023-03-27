module V1
  module Entities
    class City < Grape::Entity
      root 'cities', 'city'

      expose :id,
             :name,
             :created_at,
             :updated_at

      expose :country, using: Entities::Country do |city, _options|
        city.country
      end
    end
  end
end
