require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Options do
  include_context 'base'

  describe 'GET /options' do
    context 'get options' do
      let(:options) { create_list :option, 5 }

      before do
        options
        get('/options', headers: headers)
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['options'].size).to eql 5
        json['options'].last do |option|
          expect(option['id']).to be_a Integer
          expect(option['name']).to be_a String
          expect(option['created_at']).to be_a String
          expect(option['updated_at']).to be_a String
        end
      end
    end

    context 'if user not authorization' do
      let(:options) { create_list :option, 5 }

      before do
        options
        get '/options', headers: nil
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['options'].size).to eql 5
        json['options'].last do |option|
          expect(option['id']).to be_a Integer
          expect(option['name']).to be_a String
          expect(option['created_at']).to be_a String
          expect(option['updated_at']).to be_a Strin
        end
      end
    end

    context 'default sorting' do
      let(:option1) { create :option, name: 'tv' }
      let(:option2) { create :option, name: 'washing machine' }
      let(:option3) { create :option, name: 'air conditioning' }

      before do
        option1
        option2
        option3

        get('/options', headers: headers, params: {})
      end

      it 'returns ordered options' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['options'].pluck('name')).to eql ['air conditioning', 'tv', 'washing machine']
      end
    end

    context 'check pagination' do
      let(:options) { create_list :option, 15 }

      before do
        options
        get('/options', params: { page: 1, per_page: 10 }, headers: headers)
      end

      it 'returns the proper attributes' do
        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['options'].size).to eql 10
        expect(json['meta']['total_pages']).to eql 2
        expect(json['meta']['current_page']).to eql 1
        expect(json['meta']['options_count']).to eql 15
      end
    end
  end

  describe 'POST /options' do
    context 'success' do
      it 'create option' do
        body = { name: 'tv' }
        post('/options', params: body, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(Option.all.size).to eq(1)
        expect(Option.last.name).to eq(body[:name])
        expect(response.status).to eql 201
        expect(json['option']['name']).to eql body[:name]
      end
    end

    context 'failure' do
      it 'create option if user authorization' do
        body = { name: 'tv' }
        post('/options', params: body, headers: nil)

        json = JSON.parse(response.body)

        expect(Option.all.size).to eq(0)
        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end

      it 'create option if customer user' do
        body = { name: 'tv' }
        post('/options', params: body, headers: headers)

        json = JSON.parse(response.body)

        expect(Option.all.size).to eq(0)
        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end
    end
  end
end
