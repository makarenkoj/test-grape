module V1
  class Cities < Grape::API
    include V1Base
    include AuthenticateRequest
    format :json

    resource :cities do
      namespace do
      end
    end
  end
end
