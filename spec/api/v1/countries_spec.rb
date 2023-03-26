require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Countries do
  include_context 'base'

  describe 'GET /countries' do
    context 'get countries' do
      let(:countries) { create_list :country, 5 }

      before do
        countries
        get('/countries', headers: headers)
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['countries'].size).to eql 5
        json['countries'].last do |country|
          expect(country['id']).to be_a Integer
          expect(country['name']).to be_a String
          expect(country['created_at']).to be_a String
          expect(country['updated_at']).to be_a String
        end
      end
    end

    context 'if user not authorization' do
      let(:countries) { create_list :country, 5 }

      before do
        countries
        get '/countries', headers: nil
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['countries'].size).to eql 5
        json['countries'].last do |country|
          expect(country['id']).to be_a Integer
          expect(country['name']).to be_a String
          expect(country['created_at']).to be_a String
          expect(country['updated_at']).to be_a String
        end
      end
    end

    context 'default sorting' do
      let(:country_1) { create :country, name: 'monaco' }
      let(:country_2) { create :country, name: 'australia' }
      let(:country_3) { create :country, name: 'italy' }

      before do
        country_1
        country_2
        country_3

        get('/countries', headers: headers, params: {})
      end

      it 'returns ordered countries' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['countries'].pluck('name')).to eq %w[australia italy monaco]
      end
    end

    context 'check pagination' do
      let(:countries) { create_list :country, 15 }

      before do
        countries
        get('/countries', params: { page: 2, per_page: 10 }, headers: headers)
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['countries'].size).to eql 5
        expect(json['meta']['total_pages']).to eql 2
        expect(json['meta']['current_page']).to eql 2
        expect(json['meta']['country_count']).to eql 15
      end
    end
  end

  describe 'GET /countries/:id' do
    context 'get country' do
      it 'get country' do
        country = create(:country, :with_city)
        get("/countries/#{country.id}", headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['country']['id']).to eql country.id
        expect(json['country']['name']).to eql country.name
        expect(json['country']['cities'].size).to eql 5
      end

      it 'if user not authorization' do
        country = create(:country)
        get "/countries/#{country.id}", headers: nil

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['country']['id']).to eql country.id
        expect(json['country']['name']).to eql country.name
      end
    end
  end

  describe 'POST /countries' do
    context 'success' do
      it 'create country' do
        body = { name: 'ukraine' }
        post '/countries', params: body, headers: admin_headers

        json = JSON.parse(response.body)

        expect(Country.all.size).to eq(1)
        expect(Country.last.name).to eq(body[:name])
        expect(response.status).to eql 201
        expect(json['country']['name']).to eql body[:name]
      end
    end

    context 'failure' do
      it 'create country if user authorization' do
        body = { name: 'ukraine' }
        post('/countries', params: body, headers: nil)

        json = JSON.parse(response.body)

        expect(Country.all.size).to eq(0)
        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end

      it 'create country if customer user' do
        body = { name: 'ukraine' }
        post('/countries', params: body, headers: headers)

        json = JSON.parse(response.body)

        expect(Country.all.size).to eq(0)
        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end
    end
  end
end
