FactoryBot.define do
  factory :city do
    association :country, factory: :country
    sequence(:name) { |n| "#{FFaker::Product.model}#{n + 1}" }
  end
end
