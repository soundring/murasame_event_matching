class EventGroupAdmin < ApplicationRecord
  belongs_to :event_group
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_group_id }
end
