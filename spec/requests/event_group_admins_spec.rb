require 'rails_helper'

RSpec.describe 'EventGroupAdmins', type: :request do
  describe 'DELETE /destroy' do
    let(:owner) { create(:user) }
    let(:event_group) { create(:event_group, user: owner) }
    let(:headers) { { 'ACCEPT' => 'text/vnd.turbo-stream.html' } }

    context 'オーナーを削除しようとした場合' do
      let(:admin_user) { create(:user) }
      let!(:admin_record) { create(:event_group_admin, user: admin_user, event_group: event_group) }
      let(:owner_admin) { event_group.event_group_admins.find_by(user: owner) }

      before { sign_in admin_user }

      it '削除されずフラッシュメッセージが表示されること' do
        expect do
          delete event_group_event_group_admin_path(event_group, owner_admin), headers: headers
        end.not_to change(EventGroupAdmin, :count)

        expect(flash[:alert]).to eq('オーナーは削除できません。')
        expect(response).to redirect_to(event_group_event_group_admins_path(event_group))
      end
    end

    context '他の管理者を削除する場合' do
      let(:admin_user) { owner }
      let!(:event_group_admin) { create(:event_group_admin, event_group: event_group, user: create(:user)) }

      before { sign_in admin_user }

      it '削除されること' do
        expect do
          delete event_group_event_group_admin_path(event_group, event_group_admin), headers: headers
        end.to change(EventGroupAdmin, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
