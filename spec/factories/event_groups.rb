FactoryBot.define do
  factory :event_group do
    name { "テストグループ" }
    description { "テスト説明" }
    image_url { "https://example.com/test.jpg" }
    association :user
  end
end
