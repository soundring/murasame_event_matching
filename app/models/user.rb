class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  has_many :event_groups # 作成したグループ
  has_many :event_group_admins
  has_many :administered_groups, through: :event_group_admins, source: :event_group # 管理者になってるグループ
  has_many :events, as: :eventable
end
