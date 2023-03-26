module V1
  class Users < Grape::API
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

    resource :users do
      namespace do
        desc 'Create new user', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:post]
        params do
          requires :email, type: String, desc: 'User email'
          requires :username, type: String, desc: 'Username'
          requires :password, type: String, desc: 'User password'
          optional :role, type: String, values: User::ROLES.keys, desc: 'User role type'
        end
        post do
          user = User.new(params)

          if user.save
            u_token = user.login!

            present user, with: Entities::User, token: u_token.token
          else
            error!(user.errors.messages)
            return
          end
        end

        namespace do
          before { authenticate! }

          desc 'Get users', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:get_index]
          params do
            use :pagination
          end
          get do
            users = User.all
            pagy, users = pagy(users.order(:username),
            page: params[:page], items: params[:per_page]
          )
  
            present meta: {total_pages: pagy.pages, current_page: pagy.page, users_count: pagy.count}
            present users, with: Entities::Users::Index::User
          end

          desc 'Get user', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:show]
          params do
            requires :id, type: String, desc: 'User id'
          end
          get ':id' do
            user = User.find(params[:id])

            if user == current_user
              present user, with: Entities::Users::Show::User
            else
              error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden])
              return
            end
          end

          desc 'Update user', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:put]
          params do
            requires :id, type: String, desc: 'User id'
            optional :email, type: String, desc: 'User email'
            optional :username, type: String, desc: 'Username'
            optional :password, type: String, desc: 'User password'
          end
          put ':id' do
            user = User.find(params[:id])

            if user == current_user
              user.update!(params)
              present user
            else
              error!(I18n.t('errors.access_denied'), RESPONSE_CODE[:forbidden])
              return
            end
          end

          desc 'Delete user', headers: HEADERS_DOCS, http_codes: HTTP_CODES[:delete]
          params do
            requires :id, type: String, desc: 'User id'
          end
          delete ':id' do
            user = User.find(params[:id])

            if user == current_user
              user.destroy

              RESPONSE_CODE[:ok]
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
