class EventParticipantPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    new?
  end

  def destroy?
    record.user == user || event_admin?
  end

  private

  def event_admin?
    event = record.event
    case event.eventable
    when EventGroup
      event.eventable.admin?(user)
    when User
      event.eventable == user
    else
      false
    end
  end
end
