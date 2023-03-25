FactoryBot.define do
  factory :city do
    association :country, factory: :country
    name { FFaker::Product.model }
  end
end
