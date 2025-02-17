require 'rails_helper'

RSpec.describe EventParticipant, type: :model do
  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }
    subject { build(:event_participant, user: user, event: event) }

    context 'ユーザーが既にイベントの参加者である場合' do
      before do
        create(:event_participant, user: user, event: event)
      end

      it 'バリデーションに失敗すること' do
        expect(subject).to_not be_valid
        expect(subject.errors[:user_id]).to include('は既に参加者として登録されています。')
      end
    end

    context 'ユーザーが補欠リストに存在する場合' do
      before do
        create(:event_waitlist, user: user, event: event)
      end

      it 'バリデーションに失敗すること' do
        expect(subject).to_not be_valid
        expect(subject.errors[:user_id]).to include('は既に補欠リストに存在します。')
      end
    end

    context 'ユーザーが参加者でも補欠リストにも存在しない場合' do
      it 'バリデーションを通過すること' do
        expect(subject).to be_valid
      end
    end
  end
end
