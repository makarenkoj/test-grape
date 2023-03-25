class ApplicationApi < Grape::API
  mount V1::Base
  mount Root
end
