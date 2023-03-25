FactoryBot.define do
  factory :country do
    name { FFaker::Product.brand }
  end
end
