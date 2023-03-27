FactoryBot.define do
  factory :accommodation do
    association :user, factory: %i[user admin]
    association :city, factory: :city
    title { FFaker::Tweet.tweet }
    type { Accommodation::HOSTEL }
    phone_number { FFaker::PhoneNumberUA.international_home_phone_number }
    address { FFaker::AddressUA.street_address }
    price { 100 }
    room { 3 }

    trait :with_option do
      before(:create) do |accommodation, _evaluator|
        option = create(:option)
        create(:accommodation_option, accommodation: accommodation, option: option)
      end
    end
  end
end
