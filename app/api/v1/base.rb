require 'grape-swagger'
# require 'validators/email'

module V1
  class Base < Grape::API
    mount V1::Users
    mount V1::Countries
    mount V1::Cities
    mount V1::Options

    add_swagger_documentation(
      api_version: 'v1',
      hide_documentation_path: true,
      mount_path: '/api/v1/swagger_doc',
      hide_format: true,
      info: {
        title: 'Laurus API',
        description: 'Documentation'
      }
    )
  end
end

# Dummy class to work ActiveAdmin
# class Base; end
