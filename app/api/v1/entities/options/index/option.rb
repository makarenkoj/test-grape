module V1
  module Entities
    module Options
      module Index
        class Option < Grape::Entity
          root 'options'

          expose :id,
                 :name,
                 :created_at,
                 :updated_at
        end
      end
    end
  end
end
