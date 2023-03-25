class Option < ApplicationRecord
  has_many :accommodation_options, dependent: :destroy
  has_many :accommodations, through: :accommodation_options

  validates :name, presence: true,
            length: { minimum: 2, maximum: 50 },
            uniqueness: true
end
