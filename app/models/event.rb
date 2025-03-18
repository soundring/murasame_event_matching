class Event < ApplicationRecord
  include ImageValidatable

  belongs_to :eventable, polymorphic: true

  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user

  has_many :event_waitlists, dependent: :destroy
  has_many :waitlisted_users, through: :event_waitlists, source: :user

  has_one_attached :image

  validates :title, presence: true
  validates :event_start_at, presence: true
  validates :event_end_at, presence: true, comparison: { greater_than: :event_start_at }
  validates :recruitment_start_at, presence: true
  validates :recruitment_closed_at, presence: true, comparison: { greater_than: :recruitment_start_at }
  validates :max_participants, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  enum :status, { draft: 0, published: 1, closed: 2 }

  validate :event_start_after_recruitment_start
  validate :event_start_cannot_be_in_past, if: -> { event_start_at.present? }
  validate :recruitment_start_cannot_be_in_past, if: -> { recruitment_start_at.present? }

  def full?
    return false if max_participants.nil?
    participants.count >= max_participants
  end

  def registered?(user)
    participants.include?(user) || waitlisted_users.include?(user)
  end

  def registration_for(user)
    event_participants.find_by(user: user) || event_waitlists.find_by(user: user)
  end

  private

  def event_start_after_recruitment_start
    return if event_start_at.blank? || recruitment_start_at.blank?
    return unless event_start_at < recruitment_start_at

    errors.add(:event_start_at, "は募集開始日以降の日付にしてください。")
  end

  def event_start_cannot_be_in_past
    return unless event_start_at < Date.today

    errors.add(:event_start_at, "は今日以降の日付にしてください。")
  end

  def recruitment_start_cannot_be_in_past
    return unless recruitment_start_at < Date.today

    errors.add(:recruitment_start_at, "は今日以降の日付にしてください。")
  end
end
