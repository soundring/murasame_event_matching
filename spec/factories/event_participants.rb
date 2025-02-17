FactoryBot.define do
  factory :event_participant do
    association :user
    association :event
  end
end
