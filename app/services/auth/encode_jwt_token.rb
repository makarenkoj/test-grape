module Auth
  class EncodeJWTToken
    def initialize
      @hmac_secret = Rails.application.secrets.jwt[:hmac_secret]
      @algorithm = 'HS256'
    end

    def call(matter_id:, user_id:)
      exp = 30.days.from_now.to_i
      exp_payload = {matter_id: matter_id, user_id: user_id, exp: exp}

      JWT.encode exp_payload, @hmac_secret, @algorithm
    end
  end
end
