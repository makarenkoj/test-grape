FactoryBot.define do
  factory :option do
    name { FFaker::Vehicle.model }
  end
end
