module V1
  class Countries < Grape::API
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

    resource :countries do
      namespace do
        desc 'Get country list', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:get_index]
        params do
          use :pagination
        end
        get do
          countries = Country.all
          pagy, countries = pagy(countries.order(:name),
                                 page: params[:page], items: params[:per_page])

          present meta: { total_pages: pagy.pages, current_page: pagy.page, country_count: pagy.count }
          present countries, with: Entities::Countries::Index::Country
        end

        desc 'Get country', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:show]
        params do
          requires :id, type: String, desc: 'Country id'
        end
        get ':id' do
          country = Country.find(params[:id])

          present country, with: Entities::Countries::Show::Country
        end

        namespace do
          before { authenticate! }

          desc 'Create country', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:post]
          params do
            requires :name, type: String, desc: 'Country name'
          end
          post do
            if current_user.role == User::ADMIN
              country = Country.create!(params)

              present country, with: Entities::Country
            else
              error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden])
              return
            end
          end
        end
      end
    end
  end
end
