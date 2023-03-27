FactoryBot.define do
  factory :option do
    sequence(:name) { |n| "#{FFaker::Vehicle.model}#{n + 1}" }
  end
end
