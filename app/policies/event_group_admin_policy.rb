class EventGroupAdminPolicy < ApplicationPolicy
  def index?
    admin_or_owner?
  end

  def new?
    admin_or_owner?
  end

  def create?
    admin_or_owner?
  end

  def destroy?
    record.event_group.admin?(user) && !record.event_group.owner?(record.user)
  end

  private

  def admin_or_owner?
    event_group =
      if record.respond_to?(:event_group)
        record.event_group
      elsif record.respond_to?(:proxy_association)
        record.proxy_association.owner
      end
    event_group&.admin?(user)
  end
end
