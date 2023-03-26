module V1
  module Entities
    module Countries
      module Show
        class Country < Grape::Entity
          root 'countries', 'country'

          expose :id,
                 :name,
                 :created_at,
                 :updated_at

          expose :cities, using: Entities::Cities::Show::City do |country, options|
            country.cities
          end
        end
      end
    end
  end
end
