require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Cities do
  include_context 'base'

  describe 'GET /cities' do
    context 'get cities' do
      let(:cities) { create_list :city, 5 }

      before do
        cities
        get('/cities', headers: headers)
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['cities'].size).to eql 5
        json['cities'].last do |city|
          expect(city['id']).to be_a Integer
          expect(city['name']).to be_a String
          expect(city['created_at']).to be_a String
          expect(city['updated_at']).to be_a String
        end
      end
    end

    context 'if user not authorization' do
      let(:cities) { create_list :city, 5 }

      before do
        cities
        get('/cities', headers: nil)
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['cities'].size).to eql 5
        json['cities'].last do |city|
          expect(city['id']).to be_a Integer
          expect(city['name']).to be_a String
          expect(city['created_at']).to be_a String
          expect(city['updated_at']).to be_a String
        end
      end
    end

    context 'default sorting' do
      let(:city_1) { create :city, name: 'sydney' }
      let(:city_2) { create :city, name: 'kyiv' }
      let(:city_3) { create :city, name: 'milan' }

      before do
        city_1
        city_2
        city_3

        get('/cities', headers:, params: {})
      end

      it 'returns ordered users' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['cities'].pluck('name')).to eq %w[kyiv milan sydney]
      end
    end

    context 'check pagination' do
      let(:cities) { create_list :city, 15 }

      before do
        cities
        get('/cities', params: { page: 2, per_page: 5 }, headers:)
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['cities'].size).to eql 5
        expect(json['meta']['total_pages']).to eql 3
        expect(json['meta']['current_page']).to eql 2
        expect(json['meta']['city_count']).to eql 15
      end
    end
  end

  describe 'GET /cities/:id' do
    context 'get city' do
      it 'get city' do
        city = create(:city)
        get("/cities/#{city.id}", headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['city']['id']).to eql city.id
        expect(json['city']['name']).to eql city.name
        expect(json['city']['country']['name']).to eql city.country.name
      end

      it 'if user not authorization' do
        city = create(:city)
        get("/cities/#{city.id}", headers: nil)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['city']['id']).to eql city.id
        expect(json['city']['name']).to eql city.name
        expect(json['city']['country']['id']).to eql city.country.id
      end
    end
  end

  describe 'POST /cities' do
    context 'success' do
      it 'create city' do
        country = create(:country)
        body = { country_id: country.id, name: 'kyiv' }

        post('/cities', params: body, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(City.all.size).to eq(1)
        expect(City.last.name).to eq(body[:name])
        expect(response.status).to eql 201
        expect(json['city']['name']).to eql body[:name]
        expect(json['city']['country']['name']).to eql country.name
      end
    end

    context 'failure' do
      it 'create city if user authorization' do
        country = create(:country)
        body = { country_id: country.id, name: 'kyiv' }

        post('/cities', params: body, headers: nil)

        json = JSON.parse(response.body)

        expect(City.all.size).to eq(0)
        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end

      it 'create city if customer user' do
        country = create(:country)
        body = { country_id: country.id, name: 'kyiv' }

        post('/cities', params: body, headers: headers)

        json = JSON.parse(response.body)

        expect(City.all.size).to eq(0)
        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'broken params' do
        body = { country_id: nil, name: 'kyiv' }

        post('/cities', params: body, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(City.all.size).to eq(0)
        expect(response.status).to eql 422
        expect(json['country']).to eql ['must exist']
      end
    end
  end
end
