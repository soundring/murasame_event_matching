require 'rails_helper'

RSpec.describe EventGroup, type: :model do
  describe 'バリデーション' do
    it 'nameがあれば有効であること' do
      event_group = build(:event_group)
      expect(event_group).to be_valid
    end

    it 'nameがなければ無効であること' do
      event_group = build(:event_group, name: nil)
      event_group.valid?
      expect(event_group.errors[:name]).to include("can't be blank")
    end
  end

  describe 'デフォルト画像URLの設定' do
    it 'image_urlがnilの場合、デフォルトのURLが設定されること' do
      event_group = EventGroup.new(name: 'Test Group', user: create(:user))
      event_group.valid?
      expect(event_group.image_url).to eq('https://pbs.twimg.com/profile_banners/893121515847155712/1734629052/1500x500')
    end

    it 'image_urlが設定されている場合、デフォルトのURLが設定されないこと' do
      event_group = EventGroup.new(name: 'Test Group', image_url: 'https://example.com/image.jpg', user: create(:user))
      event_group.valid?
      expect(event_group.image_url).to eq('https://example.com/image.jpg')
    end
  end
end
