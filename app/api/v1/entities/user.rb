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

      # came case format
      expose :createdAt do |user, _options|
        user.created_at
      end

      expose :updatedAt do |user, _options|
        user.created_at
      end

      expose :token, if: ->(_instance, options) { options[:token] } do |_instance, options|
        options[:token]
      end
    end
  end
end
