FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "テストイベント#{n}" }
    recruitment_start_at { Time.current + 1.minute }
    event_start_at { recruitment_start_at + 1.minute }
    event_end_at { event_start_at + 1.hour }
    recruitment_closed_at { recruitment_start_at + 30.minutes }
    max_participants { 10 }
    status { :draft }
    association :eventable, factory: :event_group

    trait :past do
      event_start_at { Time.current - 1.day }
      event_end_at { Time.current - 12.hours }
      recruitment_start_at { Time.current - 2.days }
      recruitment_closed_at { Time.current - 1.day }

      to_create { |instance| instance.save(validate: false) }
    end

    # 個人イベント
    trait :personal do
      association :eventable, factory: :user
    end
  end
end
