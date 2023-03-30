module V1
  class AccommodationsFilters < Grape::API
    include V1Base
    include AuthenticateRequest
    include TransformationParams

    helpers do
      include Pagy::Backend
      params :pagination do
        optional :page, type: Integer, desc: 'Pagination page'
        optional :per_page, type: Integer, desc: 'Entries per page'
      end
    end

    resource :accommodations_filters do
      namespace do
        before { authenticate! }
        before { snakerize }

        desc 'Filters accommodation list', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:get_index]
        params do
          use :pagination
          optional :options_ids, type: Array, desc: 'Options ids for Accommodation'
          optional :cities_ids, type: Array, desc: 'Cities ids for Accommodation'
          optional :countries_ids, type: Array, desc: 'Countries ids for Accommodation'
        end
        get do
          accommodations = AccommodationsFiltersService.call(filters: params)
          pagy, accommodations = pagy(accommodations,
                                      page: params[:page], items: params[:per_page])

          present meta: { total_pages: pagy.pages, current_page: pagy.page, accommodations_count: pagy.count }
          present accommodations, with: Entities::Accommodations::Index::Accommodation

        rescue ActiveRecord::StatementInvalid => _e
          error!(I18n.t('errors.brocken_params'), RESPONSE_CODE[:bad_request])
        end
      end
    end
  end
end
