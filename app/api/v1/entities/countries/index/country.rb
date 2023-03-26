module V1
  module Entities
    module Countries
      module Index
        class Country < Grape::Entity
          root 'countries', 'country'

          expose :id,
                 :name,
                 :created_at,
                 :updated_at
        end
      end
    end
  end
end
