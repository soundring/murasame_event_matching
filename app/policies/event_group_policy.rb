class EventGroupPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    user == record.user || record.admin?(user)
  end

  def update?
    edit?
  end

  def destroy?
    user == record.user
  end

  # TODO: イベント作成機能を実装したらコメントアウトを外す
  # def create_event?
  # end
end
