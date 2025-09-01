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
      non_draft = scope.where.not(status: :draft)
      return non_draft unless user

        personal_events = scope.where(eventable: user)
        admin_group_events = scope.where(
          eventable_type: EventGroup.name,
          eventable_id: user.administered_groups.select(:id)
        )

      non_draft.or(personal_events).or(admin_group_events)
    end
  end
end
