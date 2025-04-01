# データを初期化
puts "データベースの初期化..."
EventWaitlist.delete_all
EventParticipant.delete_all
Event.delete_all
EventGroupAdmin.delete_all
EventGroup.delete_all
User.delete_all

# テスト用の画像パスを設定
test_image_path = Rails.root.join('spec/fixtures/test_image.jpg')

# ユーザーを作成
puts "ユーザー作成..."
users = []
10.times do |n|
  display_name = ["田中太郎", "鈴木花子", "佐藤健", "山田優", "高橋誠", "伊藤さくら", "渡辺拓也", "小林美咲", "中村大輔", "加藤由美"][n]
  users << User.create!(
    email: "user#{n+1}@example.com",
    password: "password",
    display_name: display_name
  )
end

# イベントグループを作成
puts "イベントグループ作成..."
event_groups = []
group_names = ["読書会", "プログラミング勉強会", "ハイキングクラブ", "料理教室", "写真サークル"]
group_descriptions = {
  "読書会" => "月に一度、様々なジャンルの本について語り合います。",
  "プログラミング勉強会" => "初心者から上級者まで参加できるプログラミング学習コミュニティです。",
  "ハイキングクラブ" => "自然を楽しみながら健康増進を目指すグループです。",
  "料理教室" => "季節の食材を使った料理を一緒に作ります。",
  "写真サークル" => "撮影技術の向上と作品の共有を目的としたグループです。"
}

group_names.each_with_index do |name, index|
  user = users[index % users.size]
  description = group_descriptions[name]

  group = EventGroup.create!(
    name: name,
    description: description,
    user: user
  )

  # 画像を添付
  if File.exist?(test_image_path)
    group.image.attach(
      io: File.open(test_image_path),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
  end

  event_groups << group
end

# イベントグループ管理者を追加
puts "イベントグループ管理者を追加..."
event_groups.each do |group|
  # グループ作成者以外から2人をランダムに選んで管理者に追加
  admin_candidates = users.reject { |u| u.id == group.user_id }
  admin_candidates.sample(2).each do |admin|
    EventGroupAdmin.create!(
      event_group: group,
      user: admin
    )
  end
end


# イベントを作成
puts "イベントを作成..."
events = []
base_date = Time.current

# 過去のイベント
event_groups.each do |group|
  2.times do |n|
    past_date = base_date - (n+1).months
    event = Event.new(
      title: "過去の#{group.name}イベント ##{n+1}",
      subtitle: "振り返りましょう",
      description: "このイベントは既に終了しています。",
      recruitment_start_at: past_date - 2.weeks,
      event_start_at: past_date,
      event_end_at: past_date + 2.hours,
      recruitment_closed_at: past_date - 1.day,
      location: ["東京", "大阪", "名古屋", "福岡", "札幌"].sample,
      max_participants: [10, 15, 20, nil].sample,
      status: :closed,
      eventable: group
    )
    event.save(validate: false)
    events << event
  end
end


# 現在進行中のイベント
event_groups.each do |group|
  event = Event.create!(
    title: "現在募集中の#{group.name}",
    subtitle: "参加者募集中！",
    description: "只今参加者を募集しているイベントです。お早めにお申し込みください。",
    recruitment_start_at: base_date + 1.minute,
    event_start_at: base_date + 1.week,
    event_end_at: base_date + 1.week + 3.hours,
    recruitment_closed_at: base_date + 5.days,
    location: ["渋谷", "新宿", "池袋", "横浜", "千葉"].sample,
    max_participants: [5, 8, 12, 15].sample,
    status: :published,
    eventable: group
  )
  events << event
end

# 将来のイベント
event_groups.each do |group|
  3.times do |n|
    future_date = base_date + (n+1).months
    status = n.zero? ? :published : [:published, :draft].sample
    event = Event.create!(
      title: "#{group.name}の#{["春", "夏", "秋", "冬"][n % 4]}イベント",
      subtitle: "#{future_date.strftime('%Y年%m月')}開催",
      description: "#{future_date.strftime('%Y年%m月%d日')}に開催予定の#{group.name}イベントです。",
      recruitment_start_at: future_date,
      event_start_at: future_date + 1.day,
      event_end_at: future_date + 2.days,
      recruitment_closed_at: future_date + 3.days,
      location: ["オンライン", "都内某所", "代々木公園", "六本木ヒルズ", "お台場"].sample,
      max_participants: [10, 20, 30, nil].sample,
      status: status,
      eventable: group
    )

    # 画像を添付
    if n.even? && File.exist?(test_image_path)
      event.image.attach(
        io: File.open(test_image_path),
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
    end

    events << event
  end
end


# イベント参加者とキャンセル待ちを追加
puts "イベント参加者とキャンセル待ちを作成..."
events.each do |event|
  next unless event.published?

  # 参加者を追加（定員の60-90%を埋める）
  if event.max_participants
    participant_count = (event.max_participants * rand(0.6..0.9)).to_i
    users.sample(participant_count).each do |user|
      next if event.registered?(user)
      EventParticipant.create!(
        event: event,
        user: user
      )
    end
  else
    # 定員なしの場合は5-15人をランダムに参加させる
    participant_count = rand(5..15)
    users.sample(participant_count).each do |user|
      next if event.registered?(user)
      EventParticipant.create!(
        event: event,
        user: user
      )
    end
  end

  # イベントが満員に近い場合、キャンセル待ちを追加
  if event.max_participants && event.participants.count >= event.max_participants * 0.8
    waitlist_count = rand(2..5)
    remaining_users = users - event.participants
    remaining_users.sample(waitlist_count).each do |user|
      next if event.registered?(user)
      EventWaitlist.create!(
        event: event,
        user: user
      )
    end
  end
end


puts "作成されたデータ:"
puts "ユーザー: #{User.count}人"
puts "イベントグループ: #{EventGroup.count}グループ"
puts "イベント: #{Event.count}件"
puts "イベント参加者: #{EventParticipant.count}人"
puts "キャンセル待ち: #{EventWaitlist.count}人"

puts "シードデータ作成完了！"
