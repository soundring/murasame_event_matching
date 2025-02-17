class EventWaitlist < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :user_id, uniqueness: { scope: :event_id, message: :already_on_waitlist }
  validate :not_a_participant

  private

  def not_a_participant
    errors.add(:user_id, :already_participant) if EventParticipant.exists?(user: user, event: event)
  end
end
