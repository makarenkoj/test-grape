module AuthenticateRequest
  extend ActiveSupport::Concern

  included do
    helpers do
      # Devise methods overwrites
      def current_user
        return nil if request.headers['Authorization'].blank?

        token_data = Auth::DecodeJwtToken.new.call(token: request.headers['Authorization'], verify: false, secret: '')

        @current_user = User.by_auth_token(request.headers['Authorization'])
      end

      def authenticate!
        raise error!(I18n.t('errors.not_authenticated'), RESPONSE_CODE[:unauthorized]) if !current_user
      end

      def authenticate_request!
        if request.headers['AccessToken'].blank?
          raise error!(I18n.t('errors.bad_request'), RESPONSE_CODE[:forbidden])
        end
      end
    end
  end
end
