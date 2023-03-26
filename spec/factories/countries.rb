FactoryBot.define do
  factory :country do
    sequence(:name) { |n| "#{FFaker::Product.brand}#{n + 1}" }

    trait :with_city do
      after(:create) do |country, _evaluator|
        create_list(:city, 5, country: country)
      end
    end
  end
end
