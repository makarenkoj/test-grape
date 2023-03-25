class Email < Grape::Validations::Base
  def validate_param!(attr_name, params)
    unless /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(params[attr_name])
      raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'is not a valid email'
    end
  end
end
