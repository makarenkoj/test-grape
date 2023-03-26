module V1
  class Options < Grape::API
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

    resource :options do
      namespace do
        desc 'Get options', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:get_index]
        params do
          use :pagination
        end
        get do
          options = Option.all
          pagy, options = pagy(options.order(:name),
                               page: params[:page], items: params[:per_page])

          present meta: { total_pages: pagy.pages, current_page: pagy.page, options_count: pagy.count }
          present options, with: Entities::Options::Index::Option
        end

        namespace do
          before { authenticate! }

          desc 'Create option', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:post]
          params do
            requires :name, type: String, desc: 'Options name'
          end
          post do
            if current_user.role == User::ADMIN
              option = Option.create!(params)

              present option, with: Entities::Option
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
