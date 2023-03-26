module V1
  class Accommodations < Grape::API
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
    end

    resource :accommodations do
      namespace do
        before { authenticate! }

        desc 'Create accommodation', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:post]
        params do
          requires :title, type: String, desc: 'Accommodation title'
          requires :type, type: String, desc: "Accommodation type: #{Accommodation::TYPES.keys.join('/')}"
          requires :city_id, type: Integer, desc: 'City id'
          requires :phone_number, type: String, desc: 'Accommodation phone number'
          requires :address, type: String, desc: 'Accommodation address'
          requires :price, type: Integer, desc: 'Accommodation price'
          requires :room, type: Integer, desc: 'number of rooms in Accommodation'
          optional :options_ids, type: Array, desc: 'Options ids for Accommodation'
        end
        post do
          if current_user.role == User::ADMIN
            ActiveRecord::Base.transaction do
              options_ids = params[:options_ids] && params.delete(:options_ids) if params.include?(:options_ids)
              accommodation = current_user.accommodations.new(params)
              accommodation.save!
              options = options_ids&.map { |id| Option.find(id) }
              accommodation.options << options unless options.blank?
              present accommodation, with: Entities::Accommodation
            end
          else
            error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden])
            return
          end
        end
      end
    end
  end
end
