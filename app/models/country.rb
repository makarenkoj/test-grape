class Country < ApplicationRecord
  has_many :cities, dependent: :destroy

  validates :name, presence: true,
            length: { minimum: 2, maximum: 50 },
            uniqueness: true
end
