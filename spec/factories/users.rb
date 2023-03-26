FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "#{FFaker::Name.first_name}#{n + 1}" }
    email { FFaker::Internet.unique.email }
    password { '12345678Qq!' }
    
    trait :admin do
      role { User::ADMIN }
    end
  end
end
