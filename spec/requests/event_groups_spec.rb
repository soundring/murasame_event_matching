require 'rails_helper'

RSpec.describe "EventGroups", type: :request do
  describe "GET /index" do
    context 'サインインしてない場合' do
      it 'リダイレクトすること' do
        get event_groups_path
        expect(response).to have_http_status(302)
      end
    end

    context 'サインインしている場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it '200 OKが返されること' do
        get event_groups_path
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET /show" do
    let(:user) { create(:user) }
    let!(:event_group) { create(:event_group, user: user) }

    before do
      sign_in user
    end

    it '200 OKが返されること' do
      get event_group_path(event_group)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /new" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it '200 OKが返されること' do
      get new_event_group_path
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /create" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    context '有効なパラメータの場合' do
      it '新しいイベントグループを作成すること' do
        expect {
          post event_groups_path, params: { event_group: { name: 'New Group', description: 'Description' } }
        }.to change(EventGroup, :count).by(1)
      end

      it 'イベントグループの一覧ページにリダイレクトすること' do
        post event_groups_path, params: { event_group: { name: 'New Group', description: 'Description' } }
        expect(response).to redirect_to(event_groups_path)
      end
    end

    context '無効なパラメータの場合' do
      it '新しいイベントグループを作成しないこと' do
        expect {
          post event_groups_path, params: { event_group: { name: '', description: '' } }
        }.to change(EventGroup, :count).by(0)
      end

      it '422 エラーが返されること' do
        post event_groups_path, params: { event_group: { name: '', description: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "GET /edit" do
    let(:user) { create(:user) }
    let!(:event_group) { create(:event_group, user: user) }

    before do
      sign_in user
    end

    it '200 OKが返されること' do
      get edit_event_group_path(event_group)
      expect(response).to have_http_status(200)
    end
  end

  describe "PATCH /update" do
    let(:user) { create(:user) }
    let!(:event_group) { create(:event_group, user: user) }

    before do
      sign_in user
    end

    context '有効なパラメータの場合' do
      it 'イベントグループを更新すること' do
        patch event_group_path(event_group), params: { event_group: { name: 'Updated Name' } }
        event_group.reload
        expect(event_group.name).to eq('Updated Name')
      end

      it 'イベントグループの詳細ページにリダイレクトすること' do
        patch event_group_path(event_group), params: { event_group: { name: 'Updated Name' } }
        expect(response).to redirect_to(event_group_path(event_group))
      end
    end

    context '無効なパラメータの場合' do
      it 'イベントグループを更新しないこと' do
        patch event_group_path(event_group), params: { event_group: { name: '' } }
        expect(event_group.name).not_to eq('')
      end

      it '422 エラーが返されること' do
        patch event_group_path(event_group), params: { event_group: { name: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE /destroy" do
    let(:user) { create(:user) }
    let!(:event_group) { create(:event_group, user: user) }

    before do
      sign_in user
    end

    it 'イベントグループを削除すること' do
      expect {
        delete event_group_path(event_group)
      }.to change(EventGroup, :count).by(-1)
    end

    it 'イベントグループの一覧ページにリダイレクトすること' do
      delete event_group_path(event_group)
      expect(response).to redirect_to(event_groups_path)
    end
  end
end
