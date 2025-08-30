require 'rails_helper'

RSpec.describe "EventGroupAdmins", type: :request do
  let(:event_group) { create(:event_group) }
  let(:owner) { event_group.user }

  RSpec.shared_examples '管理者GETアクセスが必要なアクション' do
    context 'サインインしていない場合' do
      it 'ログインページにリダイレクトすること' do
        subject
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'サインインしている場合' do
      before { sign_in user }

      context 'イベントグループの管理者である場合' do
        let(:user) { owner }

        it '200 OKが返されること' do
          subject
          expect(response).to have_http_status(:ok)
        end
      end

      context 'イベントグループの管理者ではない場合' do
        let(:user) { create(:user) }
        it '403 Forbiddenが返されること' do
          subject
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'GET /index' do
    subject { get event_group_event_group_admins_path(event_group) }
    it_behaves_like '管理者GETアクセスが必要なアクション'
  end

  describe 'GET /new' do
    subject { get new_event_group_event_group_admin_path(event_group) }
    it_behaves_like '管理者GETアクセスが必要なアクション'
  end

  describe "POST /create" do
    context '権限のあるユーザーの場合' do
      before { sign_in owner }

      context '有効なパラメータの場合' do
        let(:new_user) { create(:user) }

        it '管理者が追加されること' do
          expect {
            post event_group_event_group_admins_path(event_group),
                 params: { event_group_admin: { user_id: new_user.id, event_group_id: event_group.id } },
                 headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          }.to change(EventGroupAdmin, :count).by(1)
          expect(response).to have_http_status(:success)
        end
      end

      context '無効なパラメータの場合' do
        it '管理者が追加されずフラッシュメッセージが表示されること' do
          expect {
            post event_group_event_group_admins_path(event_group),
                 params: { event_group_admin: { user_id: owner.id, event_group_id: event_group.id } }
          }.not_to change(EventGroupAdmin, :count)
          expect(response).to redirect_to(event_group_event_group_admins_path(event_group))
          expect(flash[:alert]).to eq('登録に失敗しました。')
        end
      end
    end

    context '権限のないユーザーの場合' do
      let(:other_user) { create(:user) }
      let(:new_user) { create(:user) }
      before { sign_in other_user }

      it '管理者が追加されず、403 Forbiddenが返されること' do
        event_group
        expect {
          post event_group_event_group_admins_path(event_group),
               params: { event_group_admin: { user_id: new_user.id, event_group_id: event_group.id } }
        }.not_to change(EventGroupAdmin, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /destroy" do
    let(:headers) { { 'ACCEPT' => 'text/vnd.turbo-stream.html' } }

    context 'イベントグループのオーナーの場合' do
      before { sign_in owner }

      context '他の管理者を削除するとき' do
        let!(:event_group_admin) { create(:event_group_admin, event_group: event_group, user: create(:user)) }

        it '管理者が削除されること' do
          expect {
            delete event_group_event_group_admin_path(event_group, event_group_admin),
                   headers: headers
          }.to change(EventGroupAdmin, :count).by(-1)
          expect(response).to have_http_status(:ok)
        end
      end

      context 'オーナー自身を削除しようとするとき' do
        let!(:owner_admin) { EventGroupAdmin.find_by(user: owner, event_group: event_group) }

        it '削除されずリダイレクトすること' do
          expect {
            delete event_group_event_group_admin_path(event_group, owner_admin)
          }.not_to change(EventGroupAdmin, :count)
          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to(event_group_event_group_admins_path(event_group))
          expect(flash[:alert]).to eq('オーナーは削除できません。')
        end
      end
    end

    context 'イベントグループの管理者がオーナーを削除しようとする場合' do
      let(:admin_user) { create(:user) }
      let!(:admin_record) { create(:event_group_admin, user: admin_user, event_group: event_group) }
      let(:owner_admin) { EventGroupAdmin.find_by(user: owner, event_group: event_group) }
      before { sign_in admin_user }

      it '削除されずリダイレクトすること' do
        expect {
          delete event_group_event_group_admin_path(event_group, owner_admin), headers: headers
        }.not_to change(EventGroupAdmin, :count)
        expect(response).to redirect_to(event_group_event_group_admins_path(event_group))
        expect(flash[:alert]).to eq('オーナーは削除できません。')
      end
    end

    context 'イベントグループの管理者ではない場合' do
      let(:admin_user) { create(:user) }
      let!(:event_group_admin) { create(:event_group_admin, user: admin_user, event_group: event_group) }
      let(:user) { create(:user) }
      before { sign_in user }

      it '削除できずリダイレクトされること' do
        expect {
          delete event_group_event_group_admin_path(event_group, event_group_admin)
        }.not_to change(EventGroupAdmin, :count)
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
