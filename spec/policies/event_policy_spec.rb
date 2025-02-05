require 'rails_helper'

RSpec.describe EventPolicy do
  subject { described_class.new(user, event) }

  let(:user) { create(:user) }
  let(:event) { create(:event, eventable: eventable, status: status) }
  let(:status) { :draft }

  context 'グループイベントの場合' do
    let(:group_owner) { create(:user) }
    let(:event_group) { create(:event_group, user: group_owner) }

    let(:group_admin_user) { create(:user) }
    let!(:event_group_admin) { create(:event_group_admin, user: group_admin_user, event_group: event_group) }

    let(:eventable) { event_group }

    context '管理者の場合' do
      let(:user) { group_admin_user }

      context '下書きのイベントの場合' do
        let(:status) { :draft }
        it { is_expected.to permit_all_actions }
      end

      context '公開中のイベントの場合' do
        let(:status) { :published }
        it { is_expected.to permit_all_actions }
      end

      context '終了したイベントの場合' do
        let(:status) { :closed }
        it { is_expected.to permit_all_actions }
      end
    end

    context '管理者でない場合' do
      context '下書きのイベントの場合' do
        let(:status) { :draft }
        it { is_expected.to permit_only_actions(%i[index]) }
      end

      context '公開中のイベントの場合' do
        let(:status) { :published }
        it { is_expected.to permit_only_actions(%i[index show]) }
      end

      context '終了したイベントの場合' do
        let(:status) { :closed }
        it { is_expected.to permit_only_actions(%i[index show]) }
      end
    end
  end

  # TODO: 個人イベントの場合のテストを追加する
  # context '個人イベントの場合' do
  #   let(:event_owner) { create(:user) }
  #   let(:eventable) { event_owner }

  #   context 'イベント作成者の場合' do
  #     let(:user) { event_owner }

  #     it { is_expected.to permit_all_actions }
  #   end

  #   context 'イベント作成者でない場合' do
  #     let(:user) { create(:user) }

  #     context '下書きのイベントの場合' do
  #       let(:status) { :draft }
  #       it { is_expected.to permit_only_actions(%i[index]) }
  #     end

  #     context '公開中のイベントの場合' do
  #       let(:status) { :published }
  #       it { is_expected.to permit_only_actions(%i[index show]) }
  #     end

  #     context '終了したイベントの場合' do
  #       let(:status) { :closed }
  #       it { is_expected.to permit_only_actions(%i[index show]) }
  #     end
  #   end
  # end
end
