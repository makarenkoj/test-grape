module Helpers
  module SharedParams
    extend Grape::API::Helpers
    include Pagy::Backend

    params :pagination do
      optional :page, type: Integer, desc: 'Pagination page'
      optional :per_page, type: Integer, desc: 'Entries per page'
    end
  end
end
