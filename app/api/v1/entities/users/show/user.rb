module V1
  module Entities
    module Users
      module Show
        class User < Grape::Entity
          root 'users', 'user'

          expose :id,
                 :email,
                 :username,
                 :role,
                 :created_at,
                 :updated_at

          # expose :accommodation, if: ->(instance, _options) { instance.admin? }, with: Entities::Accommodation::Show::Accommodation

          expose :token, if: ->(_instance, options) { options[:token] } do |_instance, options|
            options[:token]
          end
        end
      end
    end
  end
end
