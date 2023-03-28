FactoryBot.define do
  factory :booking do
    association :accommodation, factory: %i[accommodation with_option]
    association :user, factory: :user
    start_date { Time.current.to_date }
    end_date { Time.current.to_date }
  end
end
