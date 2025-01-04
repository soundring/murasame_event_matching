RSpec.describe EventGroupPolicy do
  subject { described_class.new(user, event_group) }

  let(:event_group) { create(:event_group, user: owner) }
  let(:owner) { create(:user) }

  context 'グループ作成者の場合' do
    let(:user) { owner }

    it { is_expected.to permit_all_actions }
  end

  context '管理者の場合' do
    let(:admin_user) { create(:user) }
    let(:user) { admin_user }
    let!(:event_group_admin) { create(:event_group_admin, user: admin_user, event_group: event_group) }

    it { is_expected.to permit_only_actions(%i[index show new create edit update]) }
    it { is_expected.to forbid_actions(%i[destroy]) }
  end

  context 'グループ作成者でも管理者でもない場合' do
    let(:user) { create(:user) }

    it { is_expected.to permit_only_actions(%i[index show new create]) }
  end
end
