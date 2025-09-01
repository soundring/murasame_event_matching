class EventGroupAdminPolicy < ApplicationPolicy
  def index?
    admin_or_owner?
  end
  alias new? index?
  alias create? index?

  def destroy?
    group_admin? && !group_owner?(record.user)
  end
end
