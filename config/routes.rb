Rails.application.routes.draw do
  devise_for :users
  mount ApplicationApi => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'
end
