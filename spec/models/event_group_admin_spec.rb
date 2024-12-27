require 'rails_helper'

RSpec.describe EventGroupAdmin, type: :model do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user) }
  let(:event_group) { create(:event_group, user: user) }
  let!(:event_group_admin) { create(:event_group_admin, user: admin_user, event_group: event_group) }

  describe 'バリデーション' do
    it 'ユーザーとイベントグループが存在する場合、有効であること' do
      expect(event_group_admin).to be_valid
    end

    it 'ユーザーが存在しない場合、無効であること' do
      event_group_admin.user = nil
      expect(event_group_admin).to_not be_valid
    end

    it 'イベントグループが存在しない場合、無効であること' do
      event_group_admin.event_group = nil
      expect(event_group_admin).to_not be_valid
    end

    it 'ユーザーとイベントグループの組み合わせが一意であること' do
      event_group_admin = build(:event_group_admin, user: admin_user, event_group: event_group)
      expect(event_group_admin).to_not be_valid
    end
  end
end
