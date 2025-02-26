require 'rails_helper'

RSpec.describe "EventWaitlists", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user }

  describe "DELETE /destroy" do
    context "グループイベントの場合" do
      let(:group) { create(:event_group) }
      let(:event) { create(:event, eventable: group) }

      context "自分の補欠登録の場合" do
        let!(:waitlist) { create(:event_waitlist, user: user, event: event) }

        it "自分の補欠登録が削除されること" do
          expect {
            delete waitlist_path(waitlist), params: { event_id: event.id }
          }.to change(EventWaitlist, :count).by(-1)
          expect(response).to redirect_to(event_path(event))
        end
      end

      context "イベント管理者の場合" do
        before do
          create(:event_group_admin, user: user, event_group: group)
        end

        let!(:waitlist) { create(:event_waitlist, user: other_user, event: event) }

        it "他人の補欠登録でも削除できること" do
          expect {
            delete waitlist_path(waitlist), params: { event_id: event.id }
          }.to change(EventWaitlist, :count).by(-1)
          expect(response).to redirect_to(event_path(event))
        end
      end

      context "イベント管理者ではない場合" do
        let(:other_user) { create(:user) }
        let!(:waitlist) { create(:event_waitlist, user: other_user, event: event) }

        it "他人の補欠登録は削除できず 403 Forbidden を返すこと" do
          expect {
            delete waitlist_path(waitlist), params: { event_id: event.id }
          }.not_to change(EventWaitlist, :count)
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "個人イベントの場合" do
      context "自分の補欠登録の場合" do
        it "自分の補欠登録が削除されること" do
        end
      end

      context "他人の補欠登録の場合" do
        it "削除できず 403 Forbidden を返すこと" do
        end
      end
    end
  end
end
