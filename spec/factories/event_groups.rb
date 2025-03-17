FactoryBot.define do
  factory :event_group do
    name { "テストグループ" }
    description { "テスト説明" }
    association :user
  end
end
