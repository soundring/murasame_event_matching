require 'rails_helper'

RSpec.describe "EventWaitlists", type: :request do
  let(:event) { create(:event) }
  let(:user)  { create(:user) }

  before { sign_in user }

  describe "DELETE /destroy" do
    let!(:waitlist) { create(:event_waitlist, user: user, event: event) }

    it "補欠登録が削除されること" do
      expect {
        delete waitlist_path(waitlist), params: { event_id: event.id }
      }.to change(EventWaitlist, :count).by(-1)
      expect(response).to redirect_to(event_path(event))
    end
  end
end
