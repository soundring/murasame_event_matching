require 'rails_helper'

RSpec.describe EventPolicy::Scope do
  subject(:resolved_scope) { described_class.new(user, Event.all).resolve }

  let(:user) { create(:user) }
  let!(:own_draft_event) { create(:event, eventable: user, status: :draft) }
  let!(:other_draft_event) { create(:event, status: :draft) }

  it 'includes draft events owned by the user' do
    expect(resolved_scope).to include(own_draft_event)
    expect(resolved_scope).not_to include(other_draft_event)
  end
end
