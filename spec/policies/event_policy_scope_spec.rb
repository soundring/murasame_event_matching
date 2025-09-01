require 'rails_helper'

RSpec.describe EventPolicy::Scope do
  subject(:resolved_scope) { described_class.new(user, Event.all).resolve }

  context 'when user is nil' do
    let(:user) { nil }
    let!(:published_event) { create(:event, status: :published) }
    let!(:draft_event) { create(:event, status: :draft) }

    it 'returns only non-draft events' do
      expect(resolved_scope).to include(published_event)
      expect(resolved_scope).not_to include(draft_event)
    end
  end

  context 'when user is present' do
    let(:user) { create(:user) }
    let!(:own_draft_event) { create(:event, eventable: user, status: :draft) }

    let(:admin_group) { create(:event_group) }
    let!(:event_group_admin) { create(:event_group_admin, user: user, event_group: admin_group) }
    let!(:admin_group_draft_event) { create(:event, eventable: admin_group, status: :draft) }

    let!(:other_group_draft_event) { create(:event, status: :draft) }

    it 'includes draft events owned by the user' do
      expect(resolved_scope).to include(own_draft_event)
    end

    it 'includes draft events for groups the user administers' do
      expect(resolved_scope).to include(admin_group_draft_event)
    end

    it 'excludes draft events for groups the user does not administer' do
      expect(resolved_scope).not_to include(other_group_draft_event)
    end
  end
end
