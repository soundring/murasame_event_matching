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

      before do
        sign_in user
      end

      it 'レスポンスが成功すること' do
        get dashboard_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
