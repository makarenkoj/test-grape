module V1
  class Tokens < Grape::API
    include V1Base
    include AuthenticateRequest

    resource :tokens do
      desc 'Decode JWT token, return user with session token', http_codes: [
        {code: RESPONSE_CODE[:unauthorized], message: I18n.t('errors.session.invalid')}
      ]
      params do
        requires :token, type: String, desc: 'JWT Token'
      end
      post do
        result = Auth::DecodeJwtToken.new.call(token: params[:token], verify: true, secret: Rails.application.secrets[:secret_key_base])

        error!(result[:error], RESPONSE_CODE[:unprocessable_entity]) if result.key?(:error)

        user = User.find_by!(id: result[:user_id])

        present user, with: Entities::Users::Show::User, token: user.login!.token
      end
    end
  end
end
