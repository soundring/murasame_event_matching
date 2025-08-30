class Event < ApplicationRecord
  include ImageValidatable

  belongs_to :eventable, polymorphic: true

  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user

  has_many :event_waitlists, dependent: :destroy
  has_many :waitlisted_users, through: :event_waitlists, source: :user

  has_one_attached :image

  validates :title, presence: true
  validates :recruitment_start_at, presence: true
  validates :event_start_at, presence: true
  validates :event_end_at, presence: true, comparison: { greater_than: :event_start_at }
  validates :recruitment_closed_at, presence: true, comparison: { greater_than: :recruitment_start_at }
  validates :max_participants, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :recruitment_start_at_validation
  validate :event_start_at_validation
  validate :event_end_at_validation
  validate :recruitment_closed_at_validation

  enum :status, { draft: 0, published: 1, closed: 2 }

  scope :published, -> { where(status: :published) }
  scope :now_than_after, -> { where('event_start_at >= ?', Time.current) }

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

  def recruitment_start_at_validation
    return if recruitment_start_at.blank?

    errors.add(:recruitment_start_at, "は現在日時以降にしてください。") if recruitment_start_at < Time.current
  end

  def event_start_at_validation
    return if event_start_at.blank?

    if event_start_at < Time.current
      errors.add(:event_start_at, "は現在日時以降にしてください。")
      return
    end

    return if recruitment_start_at.blank?

    if event_start_at < recruitment_start_at
      errors.add(:event_start_at, "は募集開始日時以降にしてください。")
    end
  end

  def event_end_at_validation
    return if event_end_at.blank? || event_start_at.blank?

    errors.add(:event_end_at, "はイベント開始日時より後の日時にしてください。") if event_end_at <= event_start_at
  end

  def recruitment_closed_at_validation
    return if recruitment_closed_at.blank? || recruitment_start_at.blank?

    errors.add(:recruitment_closed_at, "は募集開始日時より後の日時にしてください。") if recruitment_closed_at <= recruitment_start_at
  end
end
