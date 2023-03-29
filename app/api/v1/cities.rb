module V1
  class Cities < Grape::API
    include V1Base
    include AuthenticateRequest

    helpers do
      include Pagy::Backend
      params :pagination do
        optional :page, type: Integer, desc: 'Pagination page'
        optional :per_page, type: Integer, desc: 'Entries per page'
      end
    end

    resource :cities do
      namespace do
        desc 'Get city list', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:get_index]
        params do
          use :pagination
        end
        get do
          cities = City.all
          pagy, cities = pagy(cities.order(:name),
                              page: params[:page], items: params[:per_page])

          present meta: { total_pages: pagy.pages, current_page: pagy.page, city_count: pagy.count }
          present cities, with: Entities::Cities::Index::City
        end

        desc 'Get city', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:show]
        params do
          requires :id, type: String, desc: 'City id'
        end
        get ':id' do
          city = City.find(params[:id])

          present city, with: Entities::Cities::Show::City
        end

        namespace do
          before { authenticate! }

          desc 'Create city', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:post]
          params do
            requires :country_id, type: Integer, desc: 'Country id'
            requires :name, type: String, desc: 'City name'
          end
          post do
            if current_user.role == User::ADMIN
              city = City.create!(params)

              present city, with: Entities::City
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
