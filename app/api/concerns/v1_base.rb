module V1Base
  extend ActiveSupport::Concern

  HEADERS_DOCS = {
    Authorization: {
      description: 'Authorization Token',
      required: true,
      # default: ''
      default: Rails.env.development? ? User&.first&.user_tokens&.last&.token : ''
    }
  }.freeze

  HTTP_CODES = {
    get_index: [
      {code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden')}
    ],
    get_show: [
      {code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found')},
      {code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden')}
    ],
    post: [
      {code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden')},
      {code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages'}
    ],
    put: [
      {code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden')},
      {code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found')},
      {code: RESPONSE_CODE[:unprocessable_entity], message: 'Validation error messages'}
    ],
    delete: [
      {code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found')},
      {code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden')}
    ]
  }.freeze

  class NotAllowedParams < ArgumentError; end

  included do
    # helpers Helpers::SharedParams
    format :json
    default_format :json

    rescue_from V1Base::NotAllowedParams do |e|
      error!(e.message, RESPONSE_CODE[:unprocessable_entity])
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      error!(e.record.errors.messages, RESPONSE_CODE[:unprocessable_entity])
    end

    rescue_from ActiveRecord::RecordNotUnique do |e|
      error!(e.message, RESPONSE_CODE[:unprocessable_entity])
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      error!(e.message, RESPONSE_CODE[:not_found])
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error!(e.message, RESPONSE_CODE[:unprocessable_entity])
    end
  end
end
