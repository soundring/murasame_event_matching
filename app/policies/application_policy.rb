# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  private

  def event_group
    @event_group ||= if record.is_a?(EventGroup)
                       record
                     elsif record.respond_to?(:event_group)
                       record.event_group
                     elsif record.respond_to?(:eventable) && record.eventable.is_a?(EventGroup)
                       record.eventable
                     elsif record.respond_to?(:proxy_association)
                       owner = record.proxy_association.owner
                       owner if owner.is_a?(EventGroup)
                     end
  end

  def group_owner?(target_user = user)
    event_group&.owner?(target_user)
  end

  def group_admin?(target_user = user)
    event_group&.admin?(target_user)
  end

  def admin_or_owner?(target_user = user)
    group_owner?(target_user) || group_admin?(target_user)
  end
end
