FactoryBot.define do
  factory :country do
    name { FFaker::Product.brand }

    trait :with_city do
      after(:create) do |country, _evaluator|
        create_list(:city, 5, country: country)
      end
    end
  end
end
