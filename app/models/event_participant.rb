class EventParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :user_id, uniqueness: { scope: :event_id, message: :already_participant }
  validate :not_in_waitlist

  private

  def not_in_waitlist
    errors.add(:user_id, :already_on_waitlist) if EventWaitlist.exists?(user: user, event: event)
  end
end
