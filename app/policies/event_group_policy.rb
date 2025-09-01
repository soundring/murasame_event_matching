class EventGroupPolicy < ApplicationPolicy
  def index?
    true
  end
  alias show? index?
  alias new? index?
  alias create? index?

  def edit?
    group_owner? || group_admin?
  end
  alias update? edit?

  def destroy?
    group_owner?
  end
end
