module AuthenticateRequest
  extend ActiveSupport::Concern

  included do
    helpers do
      # Devise methods overwrites
      def current_user
        return nil if request.headers['Authorization'].blank?

        @current_user = User.by_auth_token(request.headers['Authorization'])
      end

      def authenticate!
        raise error!(I18n.t('errors.not_authenticated'), RESPONSE_CODE[:unauthorized]) unless current_user
      end

      def authenticate_request!
        return unless request.headers['AccessToken'].blank?

        raise error!(I18n.t('errors.bad_request'), RESPONSE_CODE[:forbidden])
      end
    end
  end
end
