module V1
  class Sessions < Grape::API
    include V1Base
    include AuthenticateRequest

    resource :sessions do
      desc "Authenticate and return user's object with access token", http_codes: [
        {code: RESPONSE_CODE[:unauthorized], message: I18n.t('errors.session.invalid')}
      ]
      params do
        optional :email, type: String, desc: 'User email'
        optional :username, type: String, desc: 'Username'
        requires :password, type: String, desc: 'User Password'
      end

      post do
        email = params[:email]
        password = params[:password]

        error!(I18n.t('errors.session.invalid'), RESPONSE_CODE[:unauthorized]) if password.nil?

        user = User.find_by(email: email)

        error!(I18n.t('errors.session.invalid'), RESPONSE_CODE[:unauthorized]) if user.nil? || !user.valid_password?(password)

        u_token = user.login!

        present user, with: Entities::Users::Show::User, token: u_token.token
      end

      desc 'Get current user with access token', headers: HEADERS_DOCS, http_codes: [
        {code: RESPONSE_CODE[:unauthorized], message: I18n.t('errors.session.invalid')}
      ]
      get do
        authenticate!

        u_token = current_user.login!

        present current_user, with: Entities::Users::Show::User, token: u_token.token
      end

      desc 'Destroy the access token', headers: HEADERS_DOCS, http_codes: [
        {code: RESPONSE_CODE[:unauthorized], message: I18n.t('errors.session.invalid_token')}
      ]
      delete do
        authenticate!

        auth_token = headers['Authorization']
        user_token = UserToken.find_by(token: auth_token)

        if user_token.nil?
          error!(I18n.t('errors.session.invalid_token'), RESPONSE_CODE[:unauthorized])
        else
          user_token.destroy

          present user_token.user, with: Entities::Users::Show::User
        end
      end
    end
  end
end
