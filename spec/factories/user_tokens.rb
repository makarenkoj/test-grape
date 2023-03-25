FactoryBot.define do
  factory :user_token do
    association :user, factory: :user
    token { FFaker::Identification::ssn }
  end
end
