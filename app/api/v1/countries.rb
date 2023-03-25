module V1
  class Countries < Grape::API
    include V1Base
    include AuthenticateRequest
    format :json

    resource :countries do
      namespace do

        namespace do
          before { authenticate! }

          desc 'Create country', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:post]
          params do
            requires :name, type: String, desc: 'Country name'
          end
          post do
            country = Country.create!(params)

            present country, with: Entities::Country
          end
        end
      end
    end
  end
end
