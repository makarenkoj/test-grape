# require 'devise/jwt/test_helpers'

shared_context 'base' do
  let(:current_user) { create(:user) }
  let(:current_user_token) { create(:user_token, user: current_user) }
  let(:headers) { { 'Authorization' => current_user_token.token } }

  let(:admin_user) { create(:user, :admin) }
  let(:admin_user_token) { create(:user_token, user: admin_user) }
  let(:admin_headers) { { 'Authorization' => admin_user_token.token } }
end
