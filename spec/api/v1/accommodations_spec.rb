require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Accommodations do
  include_context 'base'

  describe 'GET /accommodations' do
    context 'success' do
      it 'returns the proper attributes' do
        create_list(:accommodation, 7)

        get('/accommodations', headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodations'].size).to eql 7
        json['accommodations'].last do |accommodation|
          expect(accommodation['id']).to be_a Integer
          expect(accommodation['city_id']).to be_a Integer
          expect(accommodation['user_id']).to be_a Integer
          expect(accommodation['title']).to be_a String
          expect(accommodation['type']).to be_a String
          expect(accommodation['phone_number']).to be_a String
          expect(accommodation['address']).to be_a String
          expect(accommodation['price']).to be_a Integer
          expect(accommodation['room']).to be_a Integer
          expect(accommodation['created_at']).to be_a String
          expect(accommodation['updated_at']).to be_a String
        end
      end

      it 'check pagination' do
        create_list(:accommodation, 17)

        get('/accommodations', params: { page: 2, per_page: 10 }, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodations'].size).to eql 7
        expect(json['meta']['total_pages']).to eql 2
        expect(json['meta']['current_page']).to eql 2
        expect(json['meta']['accommodations_count']).to eql 17
      end

      it 'user unauthorization' do
        create_list(:accommodation, 17)

        get('/accommodations', params: { page: 2, per_page: 10 }, headers: nil)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodations'].size).to eql 7
      end
    end
  end

  describe 'GET /accommodations/id' do
    context 'success' do
      it 'get accommodation' do
        accommodation = create(:accommodation)

        get("/accommodations/#{accommodation.id}", headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodation']['id']).to eql accommodation.id
        expect(json['accommodation']['user_id']).to eql accommodation.user_id
        expect(json['accommodation']['city_id']).to eql accommodation.city_id
        expect(json['accommodation']['title']).to eql accommodation.title
        expect(json['accommodation']['type']).to eql accommodation.type
        expect(json['accommodation']['phone_number']).to eql accommodation.phone_number
        expect(json['accommodation']['address']).to eql accommodation.address
        expect(json['accommodation']['price']).to eql accommodation.price
        expect(json['accommodation']['room']).to eql accommodation.room
        expect(json['accommodation']['options']).to eql []
      end

      it 'get accommodation user unathorize' do
        accommodation = create(:accommodation)

        get("/accommodations/#{accommodation.id}", headers: nil)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodation']['id']).to eql accommodation.id
        expect(json['accommodation']['user_id']).to eql accommodation.user_id
        expect(json['accommodation']['city_id']).to eql accommodation.city_id
        expect(json['accommodation']['title']).to eql accommodation.title
        expect(json['accommodation']['type']).to eql accommodation.type
        expect(json['accommodation']['phone_number']).to eql accommodation.phone_number
        expect(json['accommodation']['address']).to eql accommodation.address
        expect(json['accommodation']['price']).to eql accommodation.price
        expect(json['accommodation']['room']).to eql accommodation.room
        expect(json['accommodation']['options']).to eql []
      end
    end

    context 'failure' do
      it 'accommodation id broken' do
        get('/accommodations/id', headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 404
        expect(json['error']).to eql "Couldn't find Accommodation with 'id'=id"
      end
    end
  end

  describe 'POST /accommodations' do
    context 'success' do
      it 'create accommodation' do
        city = create(:city)
        options = create_list(:option, 5)

        params = {
          city_id: city.id,
          title: FFaker::Tweet.tweet,
          type: Accommodation::HOSTEL,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 10,
          room: 1,
          options_ids: options.pluck(:id)
        }
        post('/accommodations', params: params, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(Accommodation.all.size).to eq(1)
        expect(response.status).to eql 201
        expect(json['accommodation']['user_id']).to eql admin_user.id
        expect(json['accommodation']['city_id']).to eql city.id
        expect(json['accommodation']['title']).to eql params[:title]
        expect(json['accommodation']['type']).to eql params[:type]
        expect(json['accommodation']['phone_number']).to eql params[:phone_number]
        expect(json['accommodation']['address']).to eql params[:address]
        expect(json['accommodation']['price']).to eql params[:price]
        expect(json['accommodation']['room']).to eql params[:room]
        expect(json['accommodation']['options'].map { |option| option['id'] }).to eql params[:options_ids]
      end

      it 'create accommodation' do
        city = create(:city)

        params = {
          city_id: city.id,
          title: FFaker::Tweet.tweet,
          type: Accommodation::HOSTEL,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 10,
          room: 1
        }
        post('/accommodations', params: params, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(Accommodation.all.size).to eq(1)
        expect(response.status).to eql 201
        expect(json['accommodation']['user_id']).to eql admin_user.id
        expect(json['accommodation']['city_id']).to eql city.id
        expect(json['accommodation']['title']).to eql params[:title]
        expect(json['accommodation']['type']).to eql params[:type]
        expect(json['accommodation']['phone_number']).to eql params[:phone_number]
        expect(json['accommodation']['address']).to eql params[:address]
        expect(json['accommodation']['price']).to eql params[:price]
        expect(json['accommodation']['room']).to eql params[:room]
        expect(json['accommodation']['options']).to eql []
      end
    end

    context 'failed' do
      it 'user unathorize' do
        city = create(:city)
        options = create_list(:option, 5)

        params = {
          city_id: city.id,
          title: FFaker::Tweet.tweet,
          type: Accommodation::HOSTEL,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 10,
          room: 1,
          options_ids: options.pluck(:id)
        }
        post('/accommodations', params: params, headers: nil)

        json = JSON.parse(response.body)

        expect(Accommodation.all.size).to eq(0)
        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end

      it 'user customer' do
        city = create(:city)
        options = create_list(:option, 5)

        params = {
          city_id: city.id,
          title: FFaker::Tweet.tweet,
          type: Accommodation::HOSTEL,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 10,
          room: 1,
          options_ids: options.pluck(:id)
        }
        post('/accommodations', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(Accommodation.all.size).to eq(0)
        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'broken options ids params' do
        city = create(:city)
        options = ['test']

        params = {
          city_id: city.id,
          title: FFaker::Tweet.tweet,
          type: Accommodation::HOSTEL,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 10,
          room: 1,
          options_ids: options
        }
        post('/accommodations', params: params, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 404
        expect(Accommodation.all.size).to eq(0)
        expect(json['error']).to eql "Couldn't find Option with 'id'=test"
      end

      it 'broken city id' do
        options = create_list(:option, 5)

        params = {
          city_id: 'test',
          title: FFaker::Tweet.tweet,
          type: Accommodation::HOSTEL,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 10,
          room: 1,
          options_ids: options.pluck(:id)
        }
        post('/accommodations', params: params, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(Accommodation.all.size).to eq(0)
        expect(response.status).to eql 422
        expect(json['error']).to eql 'city_id is invalid'
      end
    end
  end

  describe 'PUT /accommodations/id' do
    context 'success' do
      it 'update accommodation' do
        accommodation = create(:accommodation, user: admin_user)
        city = create(:city)
        params = {
          city_id: city.id,
          title: FFaker::Tweet.tweet,
          type: Accommodation::VILLA,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 1000,
          room: 20
        }

        put("/accommodations/#{accommodation.id}", params: params, headers: admin_headers)

        json = JSON.parse(response.body)
        expect(response.status).to eql 200

        expect(json['accommodation']['user_id']).to eql accommodation.user.id
        expect(json['accommodation']['city_id']).to eql city.id
        expect(json['accommodation']['title']).to eql params[:title]
        expect(json['accommodation']['type']).to eql params[:type]
        expect(json['accommodation']['phone_number']).to eql params[:phone_number]
        expect(json['accommodation']['address']).to eql params[:address]
        expect(json['accommodation']['price']).to eql params[:price]
        expect(json['accommodation']['room']).to eql params[:room]
      end
    end

    context 'failure' do
      it 'other user update accommodation' do
        accommodation = create(:accommodation, user: admin_user)
        city = create(:city)
        params = {
          city_id: city.id,
          title: FFaker::Tweet.tweet,
          type: Accommodation::VILLA,
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: 1000,
          room: 20
        }

        put("/accommodations/#{accommodation.id}", params: params, headers: headers)

        json = JSON.parse(response.body)
        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'broken params' do
        accommodation = create(:accommodation, user: admin_user)
        params = {
          city_id: 'city_id',
          title: FFaker::Tweet.tweet,
          type: 'VILLA',
          phone_number: FFaker::PhoneNumberUA.international_home_phone_number,
          address: FFaker::AddressUA.street_address,
          price: '1000',
          room: '20'
        }

        put("/accommodations/#{accommodation.id}", params: params, headers: admin_headers)

        json = JSON.parse(response.body)
        expect(response.status).to eql 422
        expect(json['error']).to eql 'city_id is invalid'
      end
    end
  end

  describe 'DELETE /accommodations/id' do
    context 'success' do
      it 'delete accommodation' do
        accommodation = create(:accommodation, user: admin_user)

        delete("/accommodations/#{accommodation.id}", headers: admin_headers)

        expect(response.status).to eql RESPONSE_CODE[:ok]
        expect(Accommodation.find_by(id: accommodation.id)).to be_nil
      end
    end

    context 'failure' do
      it 'other user delete accommodation' do
        accommodation = create(:accommodation, user: admin_user)

        delete("/accommodations/#{accommodation.id}", headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql RESPONSE_CODE[:forbidden]
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end
    end
  end

  describe 'PUT /accommodations/:id/update_options' do
    context 'success' do
      it 'add options' do
        options = create_list(:option, 3)
        accommodation = create(:accommodation, :with_option, user: admin_user)
        params = { options_ids: options.pluck(:id) }

        put("/accommodations/#{accommodation.id}/update_options", params: params, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodation']['options'].size).to eql 4
      end

      it 'add dublicate options' do
        accommodation = create(:accommodation, :with_option, user: admin_user)
        option = accommodation.options

        params = { options_ids: option.pluck(:id) }

        put("/accommodations/#{accommodation.id}/update_options", params: params, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodation']['options'].size).to eql 1
        expect([json['accommodation']['options'].last['id']]).to eql params[:options_ids]
      end
    end
  end
end
