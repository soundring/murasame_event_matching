class EventGroup < ApplicationRecord
  belongs_to :user # 作成者
  has_many :event_group_admins, dependent: :destroy
  has_many :admin_users, through: :event_group_admins, source: :user # 管理者

  before_validation :set_default_image_url

  validates :name, presence: true

  def set_default_image_url
    self.image_url ||= 'https://pbs.twimg.com/profile_banners/893121515847155712/1734629052/1500x500'
  end
end
