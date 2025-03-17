class EventGroup < ApplicationRecord
  belongs_to :user # 作成者
  has_many :event_group_admins, dependent: :destroy
  has_many :admin_users, through: :event_group_admins, source: :user # 管理者
  has_many :events, as: :eventable

  after_create :add_creator_as_admin

  validates :name, presence: true

  def owner?(user)
    self.user == user
  end

  def admin?(user)
    return false unless user
    admin_users.include?(user)
  end

  private

  def add_creator_as_admin
    event_group_admins.create(user: user)
  end
end
