require 'rails_helper'

RSpec.describe EventGroup, type: :model do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:event_group) { create(:event_group, user: user) }

  describe 'バリデーション' do
    it 'nameがあれば有効であること' do
      valid_event_group = build(:event_group, user: user)
      expect(valid_event_group).to be_valid
    end

    it 'nameがなければ無効であること' do
      invalid_event_group = build(:event_group, name: nil, user: user)
      expect(invalid_event_group).not_to be_valid
      expect(invalid_event_group.errors[:name]).to include("を入力してください。")
    end
  end

  describe 'callbacks' do
    it 'イベントグループ作成時に作成者が管理者として追加されること' do
      event_group = EventGroup.create(name: 'テストグループ', user: user)
      expect(event_group.admin_users).to include(user)
    end

    it '管理者追加に失敗した場合、イベントグループが作成されないこと' do
      event_groups_count = EventGroup.count
      event_group_admins_count = EventGroupAdmin.count

      event_group = build(:event_group, user: user)
      allow(event_group).to receive(:add_creator_as_admin).and_raise(ActiveRecord::RecordInvalid)

      expect {
        event_group.save!
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(EventGroup.count).to eq event_groups_count
      expect(EventGroupAdmin.count).to eq event_group_admins_count
    end
  end
  end

  describe '#admin?' do
    it '管理者ユーザーが含まれる場合、trueを返すこと' do
      create(:event_group_admin, user: admin_user, event_group: event_group)

      expect(event_group.admin?(admin_user)).to be true
    end

    it '管理者ユーザーでない場合、falseを返すこと' do
      expect(event_group.admin?(other_user)).to be false
    end

    it 'ユーザーが渡されなかった場合、falseを返すこと' do
      expect(event_group.admin?(nil)).to be false
    end
  end

  describe '画像関連' do
    it "画像を添付できること" do
      file = fixture_file_upload(
        Rails.root.join('spec/fixtures/test_image.jpg'),
        'image/jpeg'
      )

      event_group.image.attach(file)
      expect(event_group.image).to be_attached
    end
  end
end
