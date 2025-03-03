require 'rails_helper'

RSpec.describe "EventParticipants", type: :request do
  let(:event) { create(:event) }
  let(:user)  { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user }

  describe "GET /new" do
    it '200 OKが返されること' do
      get new_event_participant_path(event)
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /create" do
    context "グループイベントの場合" do
      let(:group) { create(:event_group) }
      let(:event) { create(:event, eventable: group) }

      it "参加登録されること" do
        expect {
          post event_participants_path(event)
        }.to change(EventParticipant, :count).by(1)
        expect(response).to redirect_to(event_path(event))
      end
   end
  end

  describe "DELETE /destroy" do
    context "グループイベントの場合" do
      let(:group) { create(:event_group) }
      let(:event) { create(:event, eventable: group) }

      context "自分の参加登録の場合" do
        let!(:participant) { create(:event_participant, user: user, event: event) }

        it "自分の参加登録が削除されること" do
          expect {
            delete participant_path(participant), params: { event_id: event.id }
          }.to change(EventParticipant, :count).by(-1)
          expect(response).to redirect_to(event_path(event))
        end
      end

      context "イベント管理者の場合" do
        before do
          create(:event_group_admin, user: user, event_group: group)
        end

        let!(:participant) { create(:event_participant, user: other_user, event: event) }

        it "他人の参加登録でも削除できること" do
          expect {
            delete participant_path(participant), params: { event_id: event.id }
          }.to change(EventParticipant, :count).by(-1)
          expect(response).to redirect_to(event_path(event))
        end
      end

      context "イベント管理者ではない場合" do
        let(:other_user) { create(:user) }
        let!(:participant) { create(:event_participant, user: other_user, event: event) }

        it "他人の参加登録は削除できず 403 Forbidden を返すこと" do
          expect {
            delete participant_path(participant), params: { event_id: event.id }
          }.not_to change(EventParticipant, :count)
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "個人イベントの場合" do
      context "自分の参加登録の場合" do
        it "自分の参加登録が削除されること" do
        end
      end

      context "他人の参加登録の場合" do
        it "削除できず 403 Forbidden を返すこと" do
        end
      end
    end
  end
end
