require 'rails_helper'
require 'support/shared_contexts/base'

describe V1::Bookings do
  include_context 'base'

  describe 'GET /bookings' do
    context 'success' do
      it 'get bookings' do
        user = create(:user)
        accommodation = create(:accommodation, :with_option)
        create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 1.days, end_date: Time.current + 2.days)
        create(:booking, user: user, accommodation: accommodation, start_date: Time.current + 3.days, end_date: Time.current + 7.days)
        create(:booking, user: user, start_date: Time.current + 1.days, end_date: Time.current + 2.days)

        get('/bookings', params: {}, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['bookings'].size).to eql 1
        json['bookings'].last do |booking|
          expect(booking['id']).to be_a Integer
          expect(booking['user_id']).to be_a Integer
          expect(booking['accommodation_id']).to be_a Integer
          expect(booking['start_date']).to be_a String
          expect(booking['end_date']).to be_a String
          expect(booking['created_at']).to be_a String
          expect(booking['updated_at']).to be_a String
        end
      end

      it 'get bookings with pagination' do
        create_list(:booking, 15, user: current_user)

        get('/bookings', params: { page: 1, per_page: 10 }, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['bookings'].size).to eql 10
        expect(json['meta']['total_pages']).to eql 2
        expect(json['meta']['current_page']).to eql 1
        expect(json['meta']['bookings_count']).to eql 15
      end

      it 'get user bookings with pagination' do
        user = create(:user)
        create_list(:booking, 15, user: current_user)
        create(:booking, user: user, start_date: Time.current + 1.days, end_date: Time.current + 2.days)

        get('/bookings', params: { user_id: current_user.id, page: 1, per_page: 10 }, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['bookings'].size).to eql 10
        expect(json['meta']['total_pages']).to eql 2
        expect(json['meta']['current_page']).to eql 1
        expect(json['meta']['bookings_count']).to eql 15
      end

      it 'get user bookings' do
        user = create(:user)
        accommodation = create(:accommodation, :with_option)
        booking1 = create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 3.days, end_date: Time.current + 7.days)
        booking2 = create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 1.days, end_date: Time.current + 2.days)
        booking3 = create(:booking, user: user, start_date: Time.current + 1.days, end_date: Time.current + 2.days)

        get('/bookings', params: { user_id: current_user.id }, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['bookings'].map { |booking| booking['id'] }).to eql [booking2.id, booking1.id]
        expect(json['bookings'].map { |booking| booking['id'] }).not_to include [booking3.id]
        expect(json['bookings'].size).to eql 2
      end

      it 'get accommodation bookings' do
        user = create(:user)
        accommodation = create(:accommodation, :with_option)
        booking1 = create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 1.days, end_date: Time.current + 2.days)
        booking2 = create(:booking, user: user, accommodation: accommodation, start_date: Time.current + 3.days, end_date: Time.current + 7.days)
        booking3 = create(:booking, user: user, start_date: Time.current + 1.days, end_date: Time.current + 2.days)

        get('/bookings', params: { accommodation_id: accommodation.id }, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['bookings'].map { |booking| booking['id'] }).to eql [booking1.id, booking2.id]
        expect(json['bookings'].map { |booking| booking['id'] }).not_to include [booking3.id]
        expect(json['bookings'].size).to eql 2
      end

      it 'get user accommodation bookings' do
        user = create(:user)
        accommodation = create(:accommodation, :with_option)
        booking1 = create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 1.days, end_date: Time.current + 2.days)
        booking2 = create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 3.days, end_date: Time.current + 4.days)
        booking3 = create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 6.days, end_date: Time.current + 7.days)
        booking4 = create(:booking, user: current_user, accommodation: accommodation, start_date: Time.current + 11.days, end_date: Time.current + 17.days)
        booking5 = create(:booking, user: current_user, start_date: Time.current + 3.days, end_date: Time.current + 7.days)
        booking6 = create(:booking, user: user, accommodation: accommodation, start_date: Time.current, end_date: Time.current)
        booking7 = create(:booking, user: user, start_date: Time.current + 1.days, end_date: Time.current + 2.days)

        get('/bookings', params: { user_id: current_user.id, accommodation_id: accommodation.id, page: 1, per_page: 10 }, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['bookings'].size).to eql 4
        expect(json['bookings'].map { |booking| booking['id'] }).to eql [booking1.id, booking2.id, booking3.id, booking4.id]
        expect(json['bookings'].map { |booking| booking['id'] }).not_to include [booking5.id, booking6.id, booking7.id]
      end

      it 'user without bookings' do
        create(:booking)

        get('/bookings', params: { page: 1, per_page: 10 }, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['bookings'].size).to eql 0
      end
    end

    context 'failure' do
      it 'user unauthorize' do
        create_list(:booking, 15)

        get('/bookings', params: {}, headers: nil)

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end
    end
  end

  describe 'GET /bookings/id' do
    context 'success' do
      it 'get booking' do
        booking = create(:booking, user: current_user)

        get("/bookings/#{booking.id}", params: {}, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['booking']['id']).to eql booking.id
      end

      it 'get booking if current user admin' do
        booking = create(:booking, user: current_user)

        get("/bookings/#{booking.id}", params: {}, headers: admin_headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 200
        expect(json['booking']['id']).to eql booking.id
      end
    end

    context 'failure' do
      it 'other user' do
        booking = create(:booking)

        get("/bookings/#{booking.id}", params: {}, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'user unathorization' do
        booking = create(:booking, user: current_user)

        get("/bookings/#{booking.id}", params: {}, headers: nil)

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end
    end
  end

  describe 'POST /bookings' do
    context 'seccess' do
      it 'create booking' do
        accommodation = create(:accommodation, :with_option)
        params = { accommodation_id: accommodation.id,
                   user_id: current_user.id,
                   start_date: Time.current + 1.days,
                   end_date: Time.current + 3.days }

        post '/bookings', params: params, headers: headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 201
        expect(json['booking']['accommodation_id']).to eql params[:accommodation_id]
        expect(json['booking']['user_id']).to eql params[:user_id]
        expect(json['booking']['start_date'].to_date).to eql params[:start_date].to_date
        expect(json['booking']['end_date'].to_date).to eql params[:end_date].to_date
      end

      it 'create booking admin for user' do
        user = create(:user)
        accommodation = create(:accommodation, :with_option)
        params = { accommodation_id: accommodation.id,
                   user_id: user.id,
                   start_date: Time.current + 1.days,
                   end_date: Time.current + 3.days }

        post '/bookings', params: params, headers: admin_headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 201
        expect(json['booking']['accommodation_id']).to eql params[:accommodation_id]
        expect(json['booking']['user_id']).to eql params[:user_id]
        expect(json['booking']['start_date'].to_date).to eql params[:start_date].to_date
        expect(json['booking']['end_date'].to_date).to eql params[:end_date].to_date
      end
    end

    context 'failure' do
      it 'create booking if accomodation user' do
        accommodation = create(:accommodation, :with_option, user: admin_user)
        params = { accommodation_id: accommodation.id,
                   user_id: accommodation.user.id,
                   start_date: Time.current + 1.days,
                   end_date: Time.current + 3.days }

        post '/bookings', params: params, headers: admin_headers

        json = JSON.parse(response.body)

        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'unathorization user' do
        accommodation = create(:accommodation, :with_option)
        params = { accommodation_id: accommodation.id,
                   user_id: accommodation.user.id,
                   start_date: Time.current + 1.days,
                   end_date: Time.current + 3.days }

        post '/bookings', params: params, headers: nil

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end
    end
  end

  describe 'PUT /bookings/id' do
    context 'success' do
      it 'update booking' do
        booking = create(:booking, user: current_user, start_date: Time.current, end_date: Time.current)

        params = { start_date: Time.current + 1.days, end_date: Time.current + 2.days }

        put("/bookings/#{booking.id}", params: params, headers: headers)

        json = JSON.parse(response.body)
        expect(response.status).to eql 200
        expect(json['booking']['start_date'].to_date).to eql params[:start_date].to_date
        expect(json['booking']['end_date'].to_date).to eql params[:end_date].to_date
      end

      it 'admin update booking' do
        booking = create(:booking, user: current_user, start_date: Time.current, end_date: Time.current)

        params = { start_date: Time.current + 1.days, end_date: Time.current + 2.days }

        put("/bookings/#{booking.id}", params: params, headers: admin_headers)

        json = JSON.parse(response.body)
        expect(response.status).to eql 200
        expect(json['booking']['start_date'].to_date).to eql params[:start_date].to_date
        expect(json['booking']['end_date'].to_date).to eql params[:end_date].to_date
      end
    end

    context 'failure' do
      it "update someone else's booking" do
        booking = create(:booking, start_date: Time.current, end_date: Time.current)

        params = { start_date: Time.current + 1.days, end_date: Time.current + 2.days }

        put("/bookings/#{booking.id}", params: params, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 403
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'unathorization user' do
        booking = create(:booking, user: current_user, start_date: Time.current, end_date: Time.current)

        params = { start_date: Time.current + 1.days, end_date: Time.current + 2.days }

        put("/bookings/#{booking.id}", params: params, headers: nil)

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end
    end
  end

  describe 'DELETE /bookings/id' do
    context 'success' do
      it 'delete booking' do
        booking = create(:booking, user: current_user)

        delete("/bookings/#{booking.id}", params: {}, headers: headers)

        expect(response.status).to eql 200
        expect(Booking.find_by(id: booking.id)).to be_nil
      end

      it 'delete booking if current user admin' do
        booking = create(:booking, user: current_user)

        delete("/bookings/#{booking.id}", params: {}, headers: admin_headers)

        expect(response.status).to eql 200
        expect(Booking.find_by(id: booking.id)).to be_nil
      end
    end

    context 'failure' do
      it 'other user' do
        booking = create(:booking)

        delete("/bookings/#{booking.id}", params: {}, headers: headers)

        json = JSON.parse(response.body)

        expect(response.status).to eql 403
        expect(Booking.find_by(id: booking.id)).to eql booking
        expect(json['error']).to eql I18n.t('errors.access_denied')
      end

      it 'unathorization user' do
        booking = create(:booking, user: current_user)

        delete("/bookings/#{booking.id}", params: {}, headers: nil)

        json = JSON.parse(response.body)

        expect(response.status).to eql 401
        expect(json['error']).to eql I18n.t('errors.not_authenticated')
      end
    end
  end
end
