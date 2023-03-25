module V1
  module Entities
    class Country < Grape::Entity
      root 'countries', 'country'

      expose :id,
             :name,
             :created_at,
             :updated_at
    end
  end
end
