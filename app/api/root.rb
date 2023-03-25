class Root < Grape::API
  format :json

  get '/' do
    status :ok
  end
end
