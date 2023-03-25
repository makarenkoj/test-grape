FactoryBot.define do
  factory :accommodation_option do
    association :accommodation, factory: :accommodation
    association :option, factory: :option
  end
end
