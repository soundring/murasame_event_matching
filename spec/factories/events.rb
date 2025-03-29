FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "テストイベント#{n}" }
    event_start_at { Date.current + 1.day }
    event_end_at { Date.current + 2.days }
    recruitment_start_at { Date.current }
    recruitment_closed_at { Date.current + 1.day }
    max_participants { 10 }
    status { :draft }
    association :eventable, factory: :event_group

    # 過去のイベント
    trait :past do
      to_create do |event|
        event.save(validate: false)
        event.update_columns(
          event_start_at: 1.week.ago,
          event_end_at: 6.days.ago,
          recruitment_start_at: 2.weeks.ago,
          recruitment_closed_at: 1.week.ago,
          status: 'closed'
        )
      end
    end

    # 開催中のイベント
    trait :ongoing do
      status { :published }
      event_start_at { Date.current }
      event_end_at { Date.current + 1.day }
    end

    # 未来のイベント
    trait :future do
      status { :published }
      recruitment_start_at { Date.current }
      recruitment_closed_at { Date.current + 1.week }
      event_start_at { Date.current + 1.week }
      event_end_at { Date.current + 1.week + 1.day }
    end

    # 個人イベント
    trait :personal do
      association :eventable, factory: :user
    end
  end
end
