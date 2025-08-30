require 'rails_helper'

RSpec.describe EventGroupAdminPolicy do
  subject { described_class.new(user, event_group_admin) }

  let(:owner) { create(:user) }
  let(:event_group) { create(:event_group, user: owner) }

  context '管理者の場合' do
    let(:user) { admin_user }
    let(:admin_user) { create(:user) }
    let!(:admin_record) { create(:event_group_admin, user: admin_user, event_group: event_group) }

    context '削除対象がオーナーでない場合' do
      let(:event_group_admin) { create(:event_group_admin, event_group: event_group, user: create(:user)) }

      it { is_expected.to permit_actions(%i[destroy]) }
    end

    context '削除対象がオーナーの場合' do
      let(:event_group_admin) { event_group.event_group_admins.find_by(user: owner) }

      it { is_expected.to forbid_actions(%i[destroy]) }
    end
  end

  context '管理者でない場合' do
    let(:user) { create(:user) }
    let(:event_group_admin) { create(:event_group_admin, event_group: event_group, user: create(:user)) }

    it { is_expected.to forbid_actions(%i[destroy]) }
  end
end
