module V1
  class Bookings < Grape::API
    include V1Base
    include AuthenticateRequest
    format :json

    # helpers SharedParams
    helpers do
      include Pagy::Backend
      params :pagination do
        optional :page, type: Integer, desc: 'Pagination page'
        optional :per_page, type: Integer, desc: 'Entries per page'
      end

      def access_denied?(user, accommodation)
        current_user == user && user != accommodation.user && user.role != User::ADMIN || current_user.role == User::ADMIN && user != accommodation.user && user.role != User::ADMIN
      end
    end

    resource :bookings do
      namespace do
        before { authenticate! }

        desc 'Get bookings list', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:get_index]
        params do
          use :pagination
          optional :user_id, type: Integer, desc: 'User id'
          optional :accommodation_id, type: Integer, desc: 'Accommodation id'
        end
        get do
          if current_user.role == User::ADMIN && params[:user_id].present?
            user = User.find(params[:user_id])
          elsif current_user == User.find_by(id: params[:user_id])
            user = current_user
          else
            user = current_user.role == User::ADMIN ? nil : current_user
          end

          accommodation = params[:accommodation_id].present? ? Accommodation.find(params[:accommodation_id]) : nil

          pagy, bookings = pagy(BookingsService.call(user_id: user&.id, accommodation_id: accommodation&.id),
                                                     page: params[:page], items: params[:per_page])

          present meta: { total_pages: pagy.pages, current_page: pagy.page, bookings_count: pagy.count }
          present bookings, with: Entities::Bookings::Index::Booking
        end

        desc 'Get booking', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:show]
        params do
          requires :id, type: Integer, desc: 'Booking id'
        end
        get ':id' do
          booking = Booking.find(params[:id])

          return error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden]) unless current_user == booking.user || current_user.role == User::ADMIN

          present booking, with: Entities::Bookings::Show::Booking
        end

        desc 'Create booking', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:post]
        params do
          requires :accommodation_id, type: Integer, desc: 'Accommodation id'
          requires :user_id, type: Integer, desc: 'User id'
          requires :start_date, type: Date, desc: 'Start booking'
          requires :end_date, type: Date, desc: 'End booking'
        end
        post do
          user = User.find(params[:user_id])
          accommodation = Accommodation.find(params[:accommodation_id])

          return error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden]) if !access_denied?(user, accommodation)

          booking = user.bookings.new(params)

          if booking.save
            present booking, with: Entities::Bookings::Show::Booking
          else
            error!(user.errors, success: false)
          end
        end

        desc 'Update booking', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:put]
        params do
          requires :id, type: Integer, desc: 'Booking id'
          requires :start_date, type: Date, desc: 'Start booking'
          requires :end_date, type: Date, desc: 'End booking'
        end
        put ':id' do
          booking = Booking.find(params[:id])
          return error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden]) unless current_user == booking.user || current_user.role == User::ADMIN

          booking.update(params)
          present booking, with: Entities::Bookings::Show::Booking
        end

        desc 'Delete booking', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:delete]
        params do
          requires :id, type: Integer, desc: 'Booking id'
        end
        delete ':id' do
          booking = Booking.find(params[:id])

          return error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden]) unless current_user == booking.user || current_user.role == User::ADMIN

          booking.destroy
          RESPONSE_CODE[:ok]
        end
      end
    end
  end
end
