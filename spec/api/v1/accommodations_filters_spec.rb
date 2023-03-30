require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::AccommodationsFilters do
  include_context 'base'

  describe 'GET /accommodations_filters' do
    context 'filters accommodations' do
      let(:country1) { create(:country) }
      let(:country2) { create(:country) }
      let(:country3) { create(:country) }

      let(:city1) { create(:city, country: country1) }
      let(:city2) { create(:city, country: country2) }
      let(:city3) { create(:city, country: country3) }

      let(:option1) { create(:option) }
      let(:option2) { create(:option) }

      let!(:accommodation1) { create(:accommodation, :with_option, city: city1) }
      let!(:accommodation2) { create(:accommodation, :with_option, city: city2) }
      let!(:accommodation3) { create(:accommodation, :with_option, city: city3) }

      let!(:accommodation_option) { create(:accommodation_option, option: option1, accommodation: accommodation1) }

      it 'return with option filters' do
        params = { options_ids: [option1.id, accommodation2.options.last.id] }

        get('/accommodations_filters', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodations'].first['id']).to eql accommodation1.id
        expect(json['accommodations'].last['id']).to eql accommodation2.id
        expect(json['meta']['accommodations_count']).to eql 2
      end

      it 'use all filters filters' do
        params = { countries_ids: [country1.id],
                   options_ids: [option1.id],
                   cities_ids: [city1.id] }

        get('/accommodations_filters', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodations'].last['id']).to eql accommodation1.id
        expect(json['meta']['accommodations_count']).to eql 1
      end

      it 'return with cities filters' do
        params = { cities_ids: [city3.id, city2.id] }

        get('/accommodations_filters', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodations'].first['id']).to eql accommodation2.id
        expect(json['accommodations'].last['id']).to eql accommodation3.id
        expect(json['meta']['accommodations_count']).to eql 2
      end

      it 'return with countries filters' do
        params = { countries_ids: [country1.id, country3.id] }

        get('/accommodations_filters', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['accommodations'].first['id']).to eql accommodation1.id
        expect(json['accommodations'].last['id']).to eql accommodation3.id
        expect(json['meta']['accommodations_count']).to eql 2
      end

      it 'return with out filters' do
        params = {}

        get('/accommodations_filters', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['meta']['accommodations_count']).to eql 3
      end

      it 'return with broken filters' do
        params = { countries_ids: ['country1.id', country3.id] }

        get('/accommodations_filters', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 400
        expect(json['error']).to eql I18n.t('errors.brocken_params')
      end

      it 'return with broken filters' do
        params = { countries_ids: '[ country3.id]' }

        get('/accommodations_filters', params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 422
        expect(json['error']).to eql 'countries_ids is invalid'
      end
    end
  end
end
