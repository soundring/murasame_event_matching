# ユーザーを作成
users = [
  User.find_or_create_by!(email: 'alice@example.com') do |user|
    user.display_name = 'アリス'
    user.password = 'password'
  end,
  User.find_or_create_by!(email: 'bob@example.com') do |user|
    user.display_name = 'ボブ'
    user.password = 'password'
  end,
  User.find_or_create_by!(email: 'charlie@example.com') do |user|
    user.display_name = 'チャーリー'
    user.password = 'password'
  end
]

# イベントグループを作成
event_groups = [
  EventGroup.find_or_create_by!(name: 'テックカンファレンス') do |group|
    group.description = 'テクノロジーに関連するイベント'
    group.user = users[0]
  end,
  EventGroup.find_or_create_by!(name: 'ミュージックフェスティバル') do |group|
    group.description = '音楽に関連するイベント'
    group.user = users[1]
  end
]

# イベントグループの管理者を割り当て
[
  { event_group: event_groups[0], user: users[0] },
  { event_group: event_groups[1], user: users[1] }
].each do |eg_admin|
  EventGroupAdmin.find_or_create_by!(event_group: eg_admin[:event_group], user: eg_admin[:user])
end

# イベントを作成
events = [
  Event.find_or_create_by!(title: 'RubyConf 2025') do |event|
    event.subtitle = 'Ruby on Rails カンファレンス'
    event.description = 'Ruby愛好家のためのカンファレンスです。'
    event.event_start_at = Date.current + 1.day
    event.event_end_at = Date.current + 2.days
    event.recruitment_start_at = Date.current
    event.recruitment_closed_at = Date.current + 1.day
    event.location = 'サンフランシスコ, CA'
    event.max_participants = 300
    event.status = :published
    event.eventable = event_groups[0]
  end,
  Event.find_or_create_by!(title: 'サマービーツ') do |event|
    event.subtitle = '音楽フェスティバル'
    event.description = '夏の音楽フェスティバルです。'
    event.event_start_at = Date.current + 1.day
    event.event_end_at = Date.current + 2.days
    event.recruitment_start_at = Date.current
    event.recruitment_closed_at = Date.current + 1.day
    event.location = 'オースティン, TX'
    event.max_participants = 500
    event.status = :draft
    event.eventable = event_groups[1]
  end
]
