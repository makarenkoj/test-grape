require 'rails_helper'

describe V1::Users do
  let(:current_user) { create(:user) }
  let(:current_user_token) { create(:user_token, user: current_user) }
  let(:headers) { {'Authorization' => current_user_token.token} }

  describe 'GET /users' do
    context 'no params' do
      let(:users) { create_list :user, 3 }

      before do
        @collection_ids = users.pluck(:id)

        get '/users', headers: headers
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        json['users'].last do |user|
          expect(user['id']).to be_a Integer
          expect(user['email']).to be_a String
          expect(user['username']).to be_a String
          expect(user['role']).to be_a String
          expect(user['created_at']).to be_a String
          expect(user['updated_at']).to be_a String
        end
      end
    end

    context 'default sorting' do
      let(:user_1) { create :user }
      let(:user_2) { create :user }
      let(:user_3) { create :user }

      before do
        current_user.update_column(:username, 'Esteban')
        user_1.update_column(:username, 'Brian')
        user_2.update_column(:username, 'Abigail')
        user_3.update_column(:username, 'Christina')

        get '/users', headers: headers, params: {}
      end

      it 'returns ordered users' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['users'].pluck('username')).to eq %w[Abigail Brian Christina Esteban]
      end
    end
  end

  describe 'GET /users/:id' do
    context 'get user' do
      it 'get current_user' do
        get "/users/#{current_user.id}", headers: headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['user']['id']).to eql current_user.id
        expect(json['user']['email']).to eql current_user.email
        expect(json['user']['username']).to eql current_user.username
        expect(json['user']['role']).to eql current_user.role
      end

      it 'get another user' do
        user = create :user

        get "/users/#{user.id}", headers: headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'not authenticated user' do
        get "/users/#{current_user.id}", headers: nil

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'success' do
      it 'create user' do
        body = { username: 'name', email: 'user@mail.com', password: '12345678Qq!' }

        post '/users', params: body, headers: nil

        json = JSON.parse(response.body)

        expect(User.all.size).to eq(1)
        expect(response.status).to eql 201
        expect(json['user']['email']).to eql body[:email]
        expect(json['user']['username']).to eql body[:username]
        expect(json['user']['role']).to eql User::CUSTOMER
      end

      it 'create admin user' do
        body = { username: 'name', email: 'user@mail.com', password: '12345678Qq!', role: User::ADMIN }

        post '/users', params: body, headers: nil

        json = JSON.parse(response.body)

        expect(User.all.size).to eq(1)
        expect(response.status).to eql 201
        expect(json['user']['email']).to eql body[:email]
        expect(json['user']['username']).to eql body[:username]
        expect(json['user']['role']).to eql body[:role]
      end

      # it 'create user if user authorization' do
      #   body = { username: 'name', email: 'user@mail.com', password: '12345678Qq!' }

      #   post '/users', params: body, headers: headers

      #   json = JSON.parse(response.body)

      #   expect(User.all.size).to eq(2)
      #   expect(response.status).to eql 201
      #   expect(json['user']['email']).to eql body[:email]
      #   expect(json['user']['username']).to eql body[:username]
      #   expect(json['user']['role']).to eql User::CUSTOMER
      # end
    end
  end

  describe 'PUT /users/:id' do
    context 'success' do
      it 'update user' do
        body = {email: 'new@test.com', username: 'newname'}

        put "/users/#{current_user.id}", params: body, headers: headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['email']).to eql body[:email]
        expect(json['username']).to eql body[:username]
        expect(json['role']).to eql current_user.role
      end

      it 'update password user' do
        body = {password: '123Password!'}

        put "/users/#{current_user.id}", params: body, headers: headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['email']).to eql current_user.email
        expect(json['username']).to eql current_user.username
        expect(json['role']).to eql current_user.role
      end
    end

    context 'failure' do
      it 'user not authorize' do
        body = {email: 'new@test.com', username: 'newname'}

        put "/users/#{current_user.id}", params: body, headers: nil

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end

      it 'update another user' do
        user = create :user
        body = {email: 'new@test.com', username: 'newname'}

        put "/users/#{user.id}", params: body, headers: headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end
    end
  end

  describe 'DELETE /users/:id' do
    context 'success' do
      it 'delete user' do
        delete "/users/#{current_user.id}", headers: headers

        expect(response.status).to eql RESPONSE_CODE[:ok]
        expect(User.find_by(id: current_user.id)).to be_nil
      end
    end

    context 'failure' do
      it 'not authenticated user' do
        delete "/users/#{current_user.id}", headers: nil
        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end

      it 'another user' do
        user = create :user

        delete "/users/#{user.id}", headers: headers
        json = JSON.parse(response.body)

        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end
    end
  end
end
