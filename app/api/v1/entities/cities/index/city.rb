module V1
  module Entities
    module Cities
      module Index
        class City < Grape::Entity
          root 'cities', 'city'

          expose :id,
                 :name,
                 :created_at,
                 :updated_at
        end
      end
    end
  end
end
