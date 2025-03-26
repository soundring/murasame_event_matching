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
    let(:day_after_tomorrow) { Date.current + 2.days }

    context "イベント開始日のバリデーション" do
      it "イベント開始日が募集開始日より前の場合、適切なエラーメッセージが表示されること" do
        event = build(:event,
          event_start_at: today,
          recruitment_start_at: tomorrow
        )
        expect(event).not_to be_valid
        expect(event.errors[:event_start_at]).to include("は募集開始日以降の日付にしてください。")
      end

      it "イベント開始日が現在日時より過去の場合、適切なエラーメッセージが表示されること" do
        event = build(:event, event_start_at: yesterday)
        expect(event).not_to be_valid
        expect(event.errors[:event_start_at]).to include("は今日以降の日付にしてください。")
      end
    end

    context "募集開始日のバリデーション" do
      it "募集開始日が現在日時より過去の場合、適切なエラーメッセージが表示されること" do
        event = build(:event, recruitment_start_at: yesterday)
        expect(event).not_to be_valid
        expect(event.errors[:recruitment_start_at]).to include("は今日以降の日付にしてください。")
      end
    end

    context "同じ日付の場合の挙動" do
      it "イベント開始日と募集開始日が同じ場合、有効であること" do
        event = build(:event,
          event_start_at: today,
          recruitment_start_at: today
        )
        expect(event).to be_valid
      end
    end

    context "終了日のバリデーション" do
      it "イベント終了日が開始日より前の場合、適切なエラーメッセージが表示されること" do
        event = build(:event,
          event_start_at: today,
          event_end_at: yesterday
        )
        expect(event).not_to be_valid
        expect(event.errors[:event_end_at]).to include("はイベント開始日時より後の日時にしてください。")
      end

      it "募集終了日が開始日より前の場合、適切なエラーメッセージが表示されること" do
        event = build(:event,
          recruitment_start_at: today,
          recruitment_closed_at: yesterday
        )
        expect(event).not_to be_valid
        expect(event.errors[:recruitment_closed_at]).to include("は募集開始日時より後の日時にしてください。")
      end
    end
  end

  describe '定員関連のバリデーション' do
    context '不正な定員値' do
      it "定員が文字列の場合、適切なエラーメッセージが表示されること" do
        event = build(:event, max_participants: "三")
        expect(event).not_to be_valid
        expect(event.errors[:max_participants]).to include("は数値でなければなりません。")
      end

      it "定員が0以下の場合、適切なエラーメッセージが表示されること" do
        event = build(:event, max_participants: 0)
        expect(event).not_to be_valid
        expect(event.errors[:max_participants]).to include("は0より大きい値にしてください。")
      end
    end
  end

  describe 'ポリモーフィック関連' do
    let(:user) { create(:user) }

    context 'eventableの検証' do
      it "eventableがない場合、適切なエラーメッセージが表示されること" do
        event = build(:event, eventable: nil)
        expect(event).not_to be_valid
        expect(event.errors[:eventable]).to include("を入力してください。")
      end

      it "eventableがUserの場合でも有効であること" do
        event = build(:event, eventable: user)
        expect(event).to be_valid
      end
    end
  end

  describe '画像関連' do
    let(:test_image) do
      fixture_file_upload(
        Rails.root.join('spec/fixtures/test_image.jpg'),
        'image/jpeg'
      )
    end

    it "画像を正常に添付できること" do
      event = create(:event)
      event.image.attach(test_image)
      expect(event.image).to be_attached
      expect(event.image.content_type).to eq('image/jpeg')
    end
  end
end
