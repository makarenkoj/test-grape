class User < ApplicationRecord
  devise :database_authenticatable, :recoverable#, :confirmable, :rememberable

  CUSTOMER = 'customer'.freeze
  ADMIN = 'admin'.freeze

  ROLES = {
    CUSTOMER => CUSTOMER,
    ADMIN => ADMIN
  }.freeze

  PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{10,32}|(.*?[^\w\s])\z/

  has_many :user_tokens, dependent: :destroy
  has_many :accommodations, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validate :password_complexity
  validates :role, presence: true, inclusion: { in: ROLES.keys, message: I18n.t('errors.user.attributes.role') }
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: Devise.email_regexp }
  validates :username, presence: true,
            length: { minimum: 4, maximum: 50 },
            uniqueness: true

  def self.by_auth_token(token)
    user_token = UserToken.find_by(token: token)
    user_token ? user_token.user : nil
  end

  def login!
    user_tokens.first_or_create
  end

  def logout!
    user_tokens.destroy_all
  end

  private

  def password_complexity
    return if password.blank? || password =~ PASSWORD_REGEX

    errors.add :password, I18n.t('errors.user.attributes.password')
  end
end
