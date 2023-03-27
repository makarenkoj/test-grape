module V1
  module Entities
    module Users
      module Index
        class User < Grape::Entity
          root 'users', 'user'

          expose :id,
                 :email,
                 :username,
                 :role,
                 :created_at,
                 :updated_at
        end
      end
    end
  end
end
