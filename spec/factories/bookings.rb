FactoryBot.define do
  factory :booking do
    association :accommodation, factory: :accommodation
    start_date { Time.current.to_date }
    end_date { Time.current.to_date }
  end
end
