require 'rails_helper'

RSpec.describe Event, type: :model do
  it "タイトルがない場合、バリデーションエラーになること" do
    event = build(:event, title: nil)
    expect(event).not_to be_valid
    expect(event.errors[:title]).to include("を入力してください。")
  end

  it "正しいenum値を持つこと" do
    expect(Event.statuses).to eq({ "draft" => 0, "published" => 1, "closed" => 2 })
  end

  describe "日付関連のバリデーション" do
    let(:yesterday) { Date.current - 1.day }
    let(:today) { Date.current }
    let(:tomorrow) { Date.current + 1.day }

    it "イベント開始日が募集開始日より前の場合、バリデーションエラーになること" do
      event = build(:event,
        event_start_at: today,
        recruitment_start_at: tomorrow
      )
      expect(event).not_to be_valid
      expect(event.errors[:event_start_at]).to include("は募集開始日以降の日付にしてください。")
    end

    it "イベント開始日が現在日時より過去の場合、バリデーションエラーになること" do
      event = build(:event, event_start_at: yesterday)
      expect(event).not_to be_valid
      expect(event.errors[:event_start_at]).to include("は今日以降の日付にしてください。")
    end

    it "募集開始日が現在日時より過去の場合、バリデーションエラーになること" do
      event = build(:event, recruitment_start_at: yesterday)
      expect(event).not_to be_valid
      expect(event.errors[:recruitment_start_at]).to include("は今日以降の日付にしてください。")
    end

    it "イベント開始日と募集開始日が同じ場合、バリデーションエラーにならないこと" do
      event = build(:event,
        event_start_at: today,
        recruitment_start_at: today
      )
      expect(event).to be_valid
    end

    it "イベント終了日が開始日より前の場合、バリデーションエラーになること" do
      event = build(:event,
        event_start_at: today,
        event_end_at: yesterday
      )
      expect(event).not_to be_valid
      expect(event.errors[:event_end_at]).to include("はイベント開始日時より後の日時にしてください。")
    end

    it "募集終了日が開始日より前の場合、バリデーションエラーになること" do
      event = build(:event,
        recruitment_start_at: today,
        recruitment_closed_at: yesterday
      )
      expect(event).not_to be_valid
      expect(event.errors[:recruitment_closed_at]).to include("は募集開始日時より後の日時にしてください。")
    end
  end

  describe '定員関連のバリデーション' do
    it "定員の値が整数でない場合、バリデーションエラーになること" do
      event = build(:event, max_participants: "三")
      expect(event).not_to be_valid
    end

    it "定員の値が0以下の場合、バリデーションエラーになること" do
      event = build(:event, max_participants: 0)
      expect(event).not_to be_valid
      expect(event.errors[:max_participants]).to include("は0より大きい値にしてください。")
    end
  end

  describe 'ポリモーフィック関連' do
    let(:user) { create(:user) }

    it "eventable" do
      event = build(:event, eventable: nil)
      expect(event).not_to be_valid
      expect(event.errors[:eventable]).to include("を入力してください。")
    end

    it "eventableがUserの場合でも有効であること" do
      event = build(:event, eventable: user)
      expect(event).to be_valid
    end
  end

  describe '画像関連' do
    it "画像を添付できること" do
      event = create(:event)

      file = fixture_file_upload(
        Rails.root.join('spec/fixtures/test_image.jpg'),
        'image/jpeg'
      )

      event.image.attach(file)
      expect(event.image).to be_attached
    end
  end
end
