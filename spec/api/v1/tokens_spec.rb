require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Tokens do
  include_context 'base'

  describe 'POST /tokens' do
    context 'success' do
      it 'returns the proper attributes' do
        user = create(:user)
        encoded_token = Auth::EncodeJwtToken.new.call(user_id: user.id)
        params = { token: encoded_token }

        post('/tokens', params: params)

        json = JSON.parse(response.body)

        expect(response.status).to eql 201
        expect(json['user']['email']).to eq user.email
        expect(json['user']['token']).to eq user.user_tokens.take.token
      end
    end

    context 'failure' do
      it 'token expired' do
        user = create(:user)
        encoded_token = Auth::EncodeJwtToken.new.call(user_id: user.id)
        params = { token: encoded_token }

        Timecop.freeze(Date.today + 31)
        post('/tokens', params: params)

        json = JSON.parse(response.body)

        expect(response.status).to eq 422
        expect(json['error']).to eq I18n.t('errors.jwt.token_expired')
      end

      it 'token param missing' do
        post('/tokens', params: {})

        json = JSON.parse(response.body)

        expect(response.status).to eq 422
        expect(json['error']).to eq 'token is missing'
      end

      it 'token is invalid' do
        post('/tokens', params: { token: 'something_really_bad' })

        json = JSON.parse(response.body)

        expect(response.status).to eq 422
        expect(json['error']).to eq I18n.t('errors.jwt.token_invalid')
      end
    end
  end
end
