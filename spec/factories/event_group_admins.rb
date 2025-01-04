FactoryBot.define do
  factory :event_group_admin do
    association :user
    association :event_group
  end
end
