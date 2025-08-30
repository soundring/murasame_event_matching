require 'rails_helper'

RSpec.describe Event, type: :model do
  it "タイトルがない場合、バリデーションエラーになること" do
    event = build(:event, title: nil)
    expect(event).not_to be_valid
    expect(event.errors[:title]).to include("を入力してください。")
  end

  it "必須の日時項目がnilでもバリデーションで例外が発生しないこと" do
    event = build(
      :event,
      recruitment_start_at: nil,
      event_start_at: nil,
      event_end_at: nil,
      recruitment_closed_at: nil
    )

    expect { event.valid? }.not_to raise_error
    expect(event.errors[:recruitment_start_at]).to include("を入力してください。")
    expect(event.errors[:event_start_at]).to include("を入力してください。")
    expect(event.errors[:event_end_at]).to include("を入力してください。")
    expect(event.errors[:recruitment_closed_at]).to include("を入力してください。")
  end

  it "正しいenum値を持つこと" do
    expect(Event.statuses).to eq({ "draft" => 0, "published" => 1, "closed" => 2 })
  end

  describe "日時関連のバリデーション" do
    around do |example|
      travel_to Time.zone.local(2025, 4, 1, 12, 0, 0)
      example.run
      travel_back
    end

    let(:base_time) { Time.current }
    let(:past) { base_time - 1.second }
    let(:now) { base_time }
    let(:future) { base_time + 1.second }
    let(:far_future) { base_time + 1.hour }

    let(:valid_contexts) do
      {
        # 基本ケース：全て最小限の有効な値
        basic: {
          recruitment_start_at: now,
          event_start_at: now,
          recruitment_closed_at: future,
          event_end_at: future
        },
        # 全て未来の異なる時刻
        all_different_times: {
          recruitment_start_at: now,
          event_start_at: now + 1.minute,
          recruitment_closed_at: now + 2.minutes,
          event_end_at: now + 3.minutes
        },
        # 同時刻境界ケース：開始が同時
        same_start_times: {
          recruitment_start_at: now,
          event_start_at: now,
          recruitment_closed_at: future,
          event_end_at: far_future
        },
        # 同時刻境界ケース：終了が同時でない（異なる値）
        different_end_times: {
          recruitment_start_at: now,
          event_start_at: now,
          recruitment_closed_at: future,
          event_end_at: far_future
        }
      }
    end

    # バリデーション検証の独自ヘルパーメソッド
    def build_event_with_dates(context, overrides = {})
      params = valid_contexts[context].merge(overrides)
      build(:event, params)
    end

    # 属性とエラーメッセージのマッピング
    let(:validation_messages) do
      {
        recruitment_start_at_past: {
          attribute: :recruitment_start_at,
          message: "は現在日時以降にしてください。"
        },
        event_start_at_past: {
          attribute: :event_start_at,
          message: "は現在日時以降にしてください。"
        },
        event_start_before_recruitment: {
          attribute: :event_start_at,
          message: "は募集開始日時以降にしてください。"
        },
        event_end_not_after_start: {
          attribute: :event_end_at,
          message: "はイベント開始日時より後の日時にしてください。"
        },
        recruitment_closed_not_after_start: {
          attribute: :recruitment_closed_at,
          message: "は募集開始日時より後の日時にしてください。"
        }
      }
    end

    context "単一の日時フィールドのバリデーション" do
      describe "募集開始日時のバリデーション" do
        it "現在より過去の場合はエラー" do
          event = build_event_with_dates(:basic, recruitment_start_at: past)
          expect(event).not_to be_valid
          expect(event.errors[validation_messages[:recruitment_start_at_past][:attribute]])
            .to include(validation_messages[:recruitment_start_at_past][:message])
        end

        it "現在時刻以降なら有効" do
          event = build_event_with_dates(:basic)
          expect(event).to be_valid
        end
      end

      describe "イベント開始日時のバリデーション" do
        it "現在より過去の場合はエラー" do
          event = build_event_with_dates(:basic, event_start_at: past)
          expect(event).not_to be_valid
          expect(event.errors[validation_messages[:event_start_at_past][:attribute]])
            .to include(validation_messages[:event_start_at_past][:message])
        end

        it "募集開始より前の場合はエラー" do
          event = build_event_with_dates(:basic,
            recruitment_start_at: future,
            event_start_at: now,
            recruitment_closed_at: far_future,
            event_end_at: far_future
          )
          expect(event).not_to be_valid
          expect(event.errors[validation_messages[:event_start_before_recruitment][:attribute]])
            .to include(validation_messages[:event_start_before_recruitment][:message])
        end

        it "募集開始と同じ時刻なら有効" do
          event = build_event_with_dates(:same_start_times)
          expect(event).to be_valid
        end

        it "募集開始より後なら有効" do
          event = build_event_with_dates(:all_different_times)
          expect(event).to be_valid
        end
      end
    end

    context "日時の前後関係のバリデーション" do
      describe "イベント終了日時のバリデーション" do
        it "イベント開始より前の場合はエラー" do
          event = build_event_with_dates(:basic,
            event_start_at: future,
            event_end_at: now
          )
          expect(event).not_to be_valid
          expect(event.errors[validation_messages[:event_end_not_after_start][:attribute]])
            .to include(validation_messages[:event_end_not_after_start][:message])
        end

        it "イベント開始と同じ場合はエラー" do
          event = build_event_with_dates(:basic,
            event_start_at: now,
            event_end_at: now
          )
          expect(event).not_to be_valid
          expect(event.errors[validation_messages[:event_end_not_after_start][:attribute]])
            .to include(validation_messages[:event_end_not_after_start][:message])
        end

        it "イベント開始より後なら有効" do
          event = build_event_with_dates(:basic)
          expect(event).to be_valid
        end
      end

      describe "募集終了日時のバリデーション" do
        it "募集開始より前の場合はエラー" do
          event = build_event_with_dates(:basic,
            recruitment_start_at: future,
            recruitment_closed_at: now,
            event_start_at: future,
            event_end_at: far_future
          )
          expect(event).not_to be_valid
          expect(event.errors[validation_messages[:recruitment_closed_not_after_start][:attribute]])
            .to include(validation_messages[:recruitment_closed_not_after_start][:message])
        end

        it "募集開始と同じ場合はエラー" do
          event = build_event_with_dates(:basic,
            recruitment_start_at: now,
            recruitment_closed_at: now,
            event_start_at: now,
            event_end_at: future
          )
          expect(event).not_to be_valid
          expect(event.errors[validation_messages[:recruitment_closed_not_after_start][:attribute]])
            .to include(validation_messages[:recruitment_closed_not_after_start][:message])
        end

        it "募集開始より後なら有効" do
          event = build_event_with_dates(:basic)
          expect(event).to be_valid
        end
      end
    end

    context "複合的なケース" do
      it "すべての日時が適切な順序で設定されていれば有効" do
        event = build_event_with_dates(:all_different_times)
        expect(event).to be_valid
      end

      it "複数の日時が無効な状態にあると複数のエラーが返される" do
        event = build_event_with_dates(:basic,
          recruitment_start_at: future,  # 未来に設定
          event_start_at: now,           # 募集開始より前になってしまう
          recruitment_closed_at: now,    # 募集開始より前になってしまう
          event_end_at: now              # イベント開始と同じになってしまう
        )
        expect(event).not_to be_valid
        expect(event.errors.size).to be >= 2
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

  describe "scopes" do
    describe ".published" do
      let!(:draft_event) { create(:event, status: :draft) }
      let!(:published_event) { create(:event, status: :published) }
      let!(:closed_event) { create(:event, status: :closed) }

      it "公開状態のイベントのみを返すこと" do
        expect(Event.published).to include(published_event)
        expect(Event.published).not_to include(draft_event, closed_event)
      end
    end

    describe ".now_than_after" do
      around do |example|
        travel_to Time.zone.local(2025, 4, 1, 12, 0, 0)
        example.run
        travel_back
      end

      let!(:past_event) do
        event = build(:event, event_start_at: Time.current - 1.second)
        event.save(validate: false) # 現在日時より前の時刻をイベント開始日時にできないので、バリデーションをスキップ
        event
      end
      let!(:current_event) do
        event = build(:event, recruitment_start_at: Time.current - 1.second, event_start_at: Time.current)
        event.save(validate: false) # 募集開始日時をイベント開始日時前にできないので、バリデーションをスキップ
        event
      end
      let!(:future_event) { create(:event, recruitment_start_at: Time.current, event_start_at: Time.current + 1.second) }

      it "現在時刻以降に開始するイベントのみを返すこと" do
        expect(Event.now_than_after).to include(current_event, future_event)
        expect(Event.now_than_after).not_to include(past_event)
      end
    end
  end

  describe "インスタンスメソッド" do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }

    describe "#full?" do
      context "定員が設定されていない場合" do
        let(:event) { create(:event, max_participants: nil) }

        it "常にfalseを返すこと" do
          expect(event.full?).to be false

          5.times { event.participants << create(:user) }
          expect(event.full?).to be false
        end
      end

      context "定員が設定されている場合" do
        let(:event) { create(:event, max_participants: 3) }

        it "参加者数が定員未満ならfalseを返すこと" do
          event.participants << user
          expect(event.full?).to be false

          event.participants << another_user
          expect(event.full?).to be false
        end

        it "参加者数が定員に達したらtrueを返すこと" do
          3.times { event.participants << create(:user) }
          expect(event.full?).to be true
        end
      end
    end

    describe "#registered?" do
      let(:event) { create(:event) }

      context "ユーザーがイベントに参加登録している場合" do
        it "trueを返すこと" do
          event.participants << user
          expect(event.registered?(user)).to be true
        end
      end

      context "ユーザーがイベントのキャンセル待ちリストに登録されている場合" do
        it "trueを返すこと" do
          event.waitlisted_users << user
          expect(event.registered?(user)).to be true
        end
      end

      context "ユーザーがイベントに登録されていない場合" do
        it "falseを返すこと" do
          expect(event.registered?(user)).to be false
        end
      end
    end

    describe "#registration_for" do
      let(:event) { create(:event) }
      let!(:participant) { create(:event_participant, event: event, user: user) }

      context "ユーザーが参加者の場合" do
        it "EventParticipantインスタンスを返すこと" do
          expect(event.registration_for(user)).to eq(participant)
        end
      end

      context "ユーザーがキャンセル待ちの場合" do
        let!(:waitlist) { create(:event_waitlist, event: event, user: another_user) }

        it "EventWaitlistインスタンスを返すこと" do
          expect(event.registration_for(another_user)).to eq(waitlist)
        end
      end

      context "ユーザーが登録されていない場合" do
        let(:unregistered_user) { create(:user) }

        it "nilを返すこと" do
          expect(event.registration_for(unregistered_user)).to be_nil
        end
      end
    end
  end
end
