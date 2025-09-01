class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    if event_group
      group_admin? || !record.draft?
    else
      record.eventable == user || !record.draft?
    end
  end

  def manage?
    if event_group
      group_admin?
    else
      record.eventable == user
    end
  end
  alias new? manage?
  alias create? manage?
  alias edit? manage?
  alias update? manage?
  alias destroy? manage?

  class Scope < ApplicationPolicy::Scope
    def resolve
      admin_group_ids = user&.administered_groups&.select(:id)
      non_draft = scope.where.not(status: :draft)
      if admin_group_ids.present?
        non_draft.or(scope.where(eventable_type: 'EventGroup', eventable_id: admin_group_ids))
      else
        non_draft
      end
    end
  end
end
