class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    if record.eventable.is_a?(EventGroup)
      user.administered_groups.exists?(record.eventable_id) || record.status != 'draft'
    else
      # TODO: 個人イベントの場合の処理を追加する
      # record.eventable == user || record.status != 'draft'
    end
  end

  def new?
    if record.eventable.is_a?(EventGroup)
      user.administered_groups.exists?(record.eventable_id)
    else
      # TODO: 個人イベントの場合の処理を追加する
      # record.eventable == user
    end
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end
end
