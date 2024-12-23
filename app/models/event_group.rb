class EventGroup < ApplicationRecord
  belongs_to :user

  before_validation :set_default_image_url

  def set_default_image_url
    self.image_url ||= 'https://pbs.twimg.com/profile_banners/893121515847155712/1734629052/1500x500'
  end
end
