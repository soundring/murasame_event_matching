class EventGroupAdminPolicy < ApplicationPolicy
  def index?
    # TODO グループの作成者か管理者ならOK
    true
  end

  def new?
    # TODO グループの作成者か管理者ならOK
    index?
  end

  def create?
    # TODO グループの作成者か管理者ならOK
    index?
  end

  def destroy?
    user != record.event_group.user_id
  end
end
