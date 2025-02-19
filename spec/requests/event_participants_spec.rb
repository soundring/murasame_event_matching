require 'rails_helper'

RSpec.describe "EventParticipants", type: :request do
  let(:event) { create(:event) }
  let(:user)  { create(:user) }

  before { sign_in user }

  describe "POST /create" do
    it "参加登録されること" do
      expect {
        post event_participants_path(event)
      }.to change(EventParticipant, :count).by(1)
      expect(response).to redirect_to(event_path(event))
    end
  end

  describe "DELETE /destroy" do
    let!(:participant) { create(:event_participant, user: user, event: event) }

    it "参加登録が削除されること" do
      expect {
        delete participant_path(participant), params: { event_id: event.id }
      }.to change(EventParticipant, :count).by(-1)
      expect(response).to redirect_to(event_path(event))
    end
  end
end
