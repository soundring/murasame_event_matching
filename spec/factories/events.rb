FactoryBot.define do
  factory :event do
    title { "テストイベント" }
    event_start_at { Date.current + 1.day }
    event_end_at { Date.current + 2.days }
    recruitment_start_at { Date.current }
    recruitment_closed_at { Date.current + 1.day }
    max_participants { 10 }
    status { :draft }
    association :eventable, factory: :event_group

    # TODO:  個人イベントを追加するためのトレイト

    trait :group do
      association :eventable, factory: :event_group
    end
  end
end
