require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Sessions do
  include_context 'base'

  describe 'POST /sessions' do
    context 'success' do
      it 'Authenticate user' do
        password = 'qwertyQ1'
        user = create(:user, password: password)

        params = {
          email: user.email,
          username: user.username,
          password: password
        }

        post('/sessions', params: params)

        json = JSON.parse(response.body)

        expect(response.status).to eql 201
        expect(json['user']['id']).to eql user.id
        expect(json['user']['email']).to eql user.email
        expect(json['user']['username']).to eql user.username
      end
    end

    context 'failure' do
      it 'Password mising' do
        password = 'qwertyQ1'
        user = create(:user, password: password)

        params = {
          email: user.email,
          username: user.username
        }

        post('/sessions', params: params)

        json = JSON.parse(response.body)

        expect(response.status).to eql 422
        expect(json['error']).to eql 'password is missing'
      end

      it 'When other password' do
        password = 'qwertyQ1'
        user = create(:user)

        params = {
          email: user.email,
          username: user.username,
          password: password
        }

        post('/sessions', params: params)

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.session.invalid')
      end

      it 'When other email' do
        password = 'qwertyQ1'
        user = create(:user, password: password)

        params = {
          email: 'user@email',
          username: user.username,
          password: password
        }

        post('/sessions', params: params)

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.session.invalid')
      end
    end
  end

  describe 'GET /sessions' do
    it 'return a user with authentication token' do
      get('/sessions', headers: headers)

      json = JSON.parse(response.body)

      expect(response.status).to eql 200
      expect(json['user']['id']).to eql current_user.id
      expect(json['user']['email']).to eql current_user.email
      expect(json['user']['username']).to eql current_user.username
    end

    it 'when authentication token is missing' do
      get('/sessions')

      json = JSON.parse(response.body)

      expect(response.status).to eql 401
      expect(json['error']).to eql I18n.t('errors.session.invalid_token')
    end
  end

  describe 'DELETE /sessions' do
    it 'delete session' do
      delete('/sessions', headers: headers)

      json = JSON.parse(response.body)

      expect(response.status).to eql 200

      expect(json['user']['id']).to eql current_user.id
      expect(json['user']['email']).to eql current_user.email
      expect(json['user']['username']).to eql current_user.username
    end

    it 'when authentication token is missing' do
      delete('/sessions')

      json = JSON.parse(response.body)

      expect(response.status).to eql 401
      expect(json['error']).to eql I18n.t('errors.session.invalid_token')
    end
  end
end
