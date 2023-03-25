FactoryBot.define do
  factory :user do
    username { FFaker::Name.first_name }
    email { FFaker::Internet.unique.email }
    password { '12345678Qq!' }
    
    trait :admin do
      role { User::ADMIN }
    end
  end
end
