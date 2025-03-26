require 'rails_helper'

RSpec.describe EventRegistrationService, type: :model do
  let(:event) { create(:event, max_participants: 1) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  describe "#create_registration!" do
    context "定員に余裕がある場合" do
      it "参加者として登録されること" do
        service = EventRegistrationService.new(user1, event)

        expect {
          service.create_registration!
        }.to change(EventParticipant, :count).by(1)

        participant = EventParticipant.last
        expect(participant.user).to eq(user1)
        expect(participant.event).to eq(event)
      end
    end

    context "定員がいっぱいの場合" do
      before do
        # 事前条件：定員(1名)が埋まっている状態
        EventParticipant.create!(user: user1, event: event)
      end

      it "待機リストに登録されること" do
        service = EventRegistrationService.new(user2, event)

        expect {
          service.create_registration!
        }.to change(EventWaitlist, :count).by(1)

        waitlist = EventWaitlist.last
        expect(waitlist.user).to eq(user2)
        expect(waitlist.event).to eq(event)
      end
    end

    context "既に参加登録済みの場合" do
      before do
        EventParticipant.create!(user: user1, event: event)
      end

      it "エラーが発生すること" do
        service = EventRegistrationService.new(user1, event)

        expect {
          service.create_registration!
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#destroy_participant!" do
    let!(:participant1) { EventParticipant.create!(user: user1, event: event) }

    context "待機者がいる場合" do
      let!(:waitlist) { EventWaitlist.create!(user: user2, event: event) }

      it "参加をキャンセルすると待機者が繰り上がること" do
        service = EventRegistrationService.new(user1, event)

        expect {
          service.destroy_participant!(participant1)
        }.to change(EventWaitlist, :count).by(-1)

        # 待機者が参加者に繰り上がっていることを確認
        new_participant = EventParticipant.last
        expect(new_participant.user).to eq(user2)
        expect(new_participant.event).to eq(event)
      end
    end

    context "待機者がいない場合" do
      it "参加がキャンセルされること" do
        service = EventRegistrationService.new(user1, event)

        expect {
          service.destroy_participant!(participant1)
        }.to change(EventParticipant, :count).by(-1)

        expect(EventParticipant.exists?(participant1.id)).to be_falsey
      end
    end
  end

  describe "#destroy_waitlist!" do
    let!(:waitlist) { EventWaitlist.create!(user: user2, event: event) }

    it "待機リストから削除されること" do
      service = EventRegistrationService.new(user2, event)

      expect {
        service.destroy_waitlist!(waitlist)
      }.to change(EventWaitlist, :count).by(-1)

      expect(EventWaitlist.exists?(waitlist.id)).to be_falsey
    end

    it "他の待機者の順番に影響を与えないこと" do
      user3 = create(:user)
      waitlist2 = EventWaitlist.create!(user: user3, event: event)
      service = EventRegistrationService.new(user2, event)

      expect {
        service.destroy_waitlist!(waitlist)
      }.to change(EventWaitlist, :count).by(-1)

      expect(EventWaitlist.exists?(waitlist2.id)).to be_truthy
    end
  end
end
