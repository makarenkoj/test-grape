module Auth
  class EncodeJwtToken
    def initialize
      @hmac_secret = Rails.application.secrets[:secret_key_base]
      @algorithm = 'HS256'
    end

    def call(user_id:)
      exp = 30.days.from_now.to_i
      exp_payload = { user_id: user_id, exp: exp }

      JWT.encode exp_payload, @hmac_secret, @algorithm
    end
  end
end
