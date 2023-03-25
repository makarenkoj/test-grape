module V1
  module Entities
    class User < Grape::Entity
      root 'users', 'user'

      expose :id,
             :email,
             :username,
             :created_at,
             :updated_at,
             :role

      expose :token, if: ->(_instance, options) { options[:token] } do |_instance, options|
        options[:token]
      end
    end
  end
end
