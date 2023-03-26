module V1
  module Entities
    class Option < Grape::Entity
      root 'options', 'option'

      expose :id,
             :name,
             :created_at,
             :updated_at
    end
  end
end
