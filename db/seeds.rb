# データを初期化
puts "Cleaning the database..."
EventWaitlist.delete_all
EventParticipant.delete_all
Event.delete_all
EventGroupAdmin.delete_all
EventGroup.delete_all
User.delete_all

# テスト用の画像パスを設定
test_image_path = Rails.root.join('spec/fixtures/test_image.jpg')

# ユーザーを作成
puts "Creating users..."
users = []
3.times do |n|
  users << User.create!(
    email: "user#{n+1}@example.com",
    password: "password"
  )
end

# イベントグループを作成
puts "Creating event groups..."
event_groups = []
users.each_with_index do |user, index|
  group = EventGroup.create!(
    name: "#{user.email.split('@').first}のグループ",
    description: "テスト用グループです。様々なイベントを開催していきます。",
    user: user
  )

  # 画像を添付（1つおきに）
  if index.even? && File.exist?(test_image_path)
    group.image.attach(
      io: File.open(test_image_path),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
  end

  event_groups << group
end

# イベントを作成
puts "Creating events..."
events = []
event_groups.each do |group|
  # グループごとに2つのイベントを作成
  2.times do |n|
    # 時間の設定をバリエーション付きで
    current_time = Time.current
    recruitment_start = current_time + 1.hour + n.hours  # 現在時刻から十分に未来の時間を設定
    start_time = recruitment_start + n.hours
    end_time = start_time + 2.hours
    recruitment_end = end_time + 1.hour

    # ステータスをバリエーション付きで
    status = case n
    when 0 then :published
    when 1 then [:draft, :closed].sample
    end

    # 定員の有無をバリエーション付きで
    max_participants = n.zero? ? 5 : nil

    event = Event.create!(
      title: "#{group.name}の#{n+1}番目のイベント",
      description: "テスト用イベントです。#{status}ステータスで、#{max_participants ? "定員#{max_participants}名" : '定員なし'}です。",
      event_start_at: start_time,
      event_end_at: end_time,
      recruitment_start_at: recruitment_start,
      recruitment_closed_at: recruitment_end,
      max_participants: max_participants,
      status: status,
      eventable: group
    )

    # 画像を添付（1つおきに）
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
puts "Creating event participants and waitlists..."
events.each do |event|
  next unless event.published?

  # 参加者を2-3名追加
  participant_count = rand(2..3)
  users.sample(participant_count).each do |user|
    next if event.registered?(user)
    EventParticipant.create!(
      event: event,
      user: user
    )
  end

  # イベントが満員の場合、キャンセル待ちを1-2名追加
  if event.full?
    waitlist_count = rand(1..2)
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

puts "Seed data creation completed!"
