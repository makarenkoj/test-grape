require 'grape-swagger'

module V1
  class Base < Grape::API
    mount V1::Users
    mount V1::Sessions
    mount V1::Tokens
    mount V1::Countries
    mount V1::Cities
    mount V1::Options
    mount V1::Accommodations
    mount V1::Bookings
    mount V1::AccommodationsFilters

    add_swagger_documentation(
      api_version: 'v1',
      hide_documentation_path: true,
      mount_path: '/api/v1/swagger_doc',
      hide_format: true,
      info: {
        title: 'test grape API',
        description: 'Documentation'
      }
    )
  end
end
