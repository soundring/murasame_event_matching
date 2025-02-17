RSpec.describe EventRegistrationService, type: :model do
  let(:event) { create(:event, max_participants: 1) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  describe "#create_registration!" do
    context "定員に余裕がある場合" do
      it "EventParticipantが作成される" do
        service = EventRegistrationService.new(user1, event)
        expect { service.create_registration! }.to change(EventParticipant, :count).by(1)
        expect(EventWaitlist.count).to eq(0)
      end
    end

    context "定員がいっぱいの場合" do
      before do
        # user1 ですでに参加1人 (max_participants=1)
        EventParticipant.create!(user: user1, event: event)
      end

      it "EventWaitlistが作成される" do
        service = EventRegistrationService.new(user2, event)
        expect { service.create_registration! }.to change(EventWaitlist, :count).by(1)
      end
    end
  end

  describe "#destroy_participant!" do
    let!(:participant1) { EventParticipant.create!(user: user1, event: event) }

    context "補欠がいる場合" do
      let!(:waitlist) { EventWaitlist.create!(user: user2, event: event) }

      it "参加を削除すると補欠が繰り上がる" do
        service = EventRegistrationService.new(user1, event)
        expect {
          service.destroy_participant!(participant1)
        }.to change(EventParticipant, :count).by(0) # 最初に1人、消して+繰り上げ→合計1人のまま
        expect(EventParticipant.last.user).to eq(user2)
        expect(EventWaitlist.count).to eq(0)
      end
    end

    context "補欠がいない場合" do
      it "単に削除されるだけ" do
        service = EventRegistrationService.new(user1, event)
        expect {
          service.destroy_participant!(participant1)
        }.to change(EventParticipant, :count).by(-1)
      end
    end
  end

  describe "#destroy_waitlist!" do
    let!(:waitlist) { EventWaitlist.create!(user: user2, event: event) }

    it "waitlistを削除する" do
      service = EventRegistrationService.new(user1, event)
      expect {
        service.destroy_waitlist!(waitlist)
      }.to change(EventWaitlist, :count).by(-1)
    end
  end
end
