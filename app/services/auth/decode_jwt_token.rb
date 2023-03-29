module Auth
  class DecodeJwtToken
    def initialize
      @algorithm = 'HS256'
    end

    def call(token:, verify:, secret:)
      JWT.decode(token, secret, verify, algorithm: @algorithm)[0].symbolize_keys
    rescue JWT::ExpiredSignature
      { error: I18n.t('errors.jwt.token_expired') }
    rescue JWT::DecodeError
      { error: I18n.t('errors.jwt.token_invalid') }
    end
  end
end
