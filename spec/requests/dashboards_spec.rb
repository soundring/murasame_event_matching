require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /show" do
    context 'サインインしてない場合' do
      it 'リダイレクトされること' do
        get dashboard_path
        expect(response).to have_http_status(302)
      end
    end

    context 'サインインしている場合' do
      let(:user) { create(:user) }
      let(:event_group) { create(:event_group) }
      let(:future_group_event) { create(:event, :future, eventable: event_group) }
      let(:ongoing_group_event) { create(:event, :ongoing, eventable: event_group) }
      let(:past_group_event) { create(:event, :past, eventable: event_group) }

      before do
        sign_in user
        create(:event_participant, event: future_group_event, user: user)
        create(:event_participant, event: ongoing_group_event, user: user)
        create(:event_participant, event: past_group_event, user: user)
      end

      it 'レスポンスが成功すること' do
        get dashboard_path
        expect(response).to have_http_status(200)
      end

      it '適切なイベントが表示されていること' do
        get dashboard_path
        expect(response.body).to include(future_group_event.title)
        expect(response.body).to include(ongoing_group_event.title)
        expect(response.body).not_to include(past_group_event.title)
      end
    end
  end
end
