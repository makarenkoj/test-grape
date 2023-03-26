require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Accommodations do
  include_context 'base'

  describe 'POST /accommodations' do
    context 'success' do
      it 'create country' do
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
        expect(json['accommodation']['options'].map{ |option| option['id'] }).to eql params[:options_ids]
      end

      it 'create country' do
        city = create(:city)
        options = create_list(:option, 5)

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
end
