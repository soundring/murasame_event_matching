FactoryBot.define do
  factory :event_waitlist do
    association :user
    association :event
  end
end
