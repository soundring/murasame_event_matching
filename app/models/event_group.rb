class EventGroup < ApplicationRecord
  belongs_to :user # 作成者
  has_many :event_group_admins, dependent: :destroy
  has_many :admin_users, through: :event_group_admins, source: :user # 管理者

  before_validation :set_default_image_url
  after_create :add_creator_as_admin

  validates :name, presence: true

  def admin?(user)
    return false unless user
    admin_users.include?(user)
  end

  private

  def set_default_image_url
    self.image_url ||= 'https://pbs.twimg.com/profile_banners/893121515847155712/1734629052/1500x500'
  end

  def add_creator_as_admin
    event_group_admins.create(user: user)
  end
end
