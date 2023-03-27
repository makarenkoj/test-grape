class Accommodation < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :user
  belongs_to :city
  has_many :accommodation_options, dependent: :destroy
  has_many :options, through: :accommodation_options
  has_many :bookings, dependent: :destroy

  APARTMENTS = 'apartments'.freeze
  HOUSE = 'house'.freeze
  ROOM = 'room'.freeze
  VILLA = 'villa'.freeze
  HOTEL = 'hotel'.freeze
  HOSTEL = 'hostel'.freeze

  TYPES = { 
    APARTMENTS => APARTMENTS,
    HOUSE => HOUSE,
    ROOM => ROOM,
    VILLA => VILLA,
    HOTEL => HOTEL,
    HOSTEL => HOSTEL
  }.freeze

  validates :title, :phone_number, :address, :price, :room, presence: true
  validates :type, presence: true, inclusion: { in: TYPES.keys, message: I18n.t('errors.accommodation.attributes.type') }

end
