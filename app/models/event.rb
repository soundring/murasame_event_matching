class Event < ApplicationRecord
  include ImageValidatable

  belongs_to :eventable, polymorphic: true

  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user

  has_many :event_waitlists, dependent: :destroy
  has_many :waitlisted_users, through: :event_waitlists, source: :user

  has_one_attached :image

  validates :title, presence: true
  validates :recruitment_start_at, presence: true,
                                    comparison: {
                                      greater_than_or_equal_to: -> { Time.current },
                                      message: "は現在日時以降にしてください。"
                                    }
  validates :event_start_at, presence: true,
                              comparison: {
                                greater_than_or_equal_to: -> { Time.current },
                                message: "は現在日時以降にしてください。"
                              }
  validates :event_start_at,
            comparison: {
              greater_than_or_equal_to: :recruitment_start_at,
              message: "は募集開始日時以降にしてください。"
            }
  validates :event_end_at, presence: true,
                           comparison: {
                             greater_than: :event_start_at,
                             message: "はイベント開始日時より後の日時にしてください。"
                           }
  validates :recruitment_closed_at, presence: true,
                                    comparison: {
                                      greater_than: :recruitment_start_at,
                                      message: "は募集開始日時より後の日時にしてください。"
                                    }
  validates :max_participants, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

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
end
