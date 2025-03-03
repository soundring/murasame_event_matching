class EventRegistrationService
  private attr_reader :user, :event

  def initialize(user, event)
    @user = user
    @event = event
  end

  # 定員に空きがある場合は参加登録し、満員の場合は補欠リストに追加する
  def create_registration!
    ActiveRecord::Base.transaction do
      event.full? ? create_waitlist! : create_participant!
    end
  end

  # 参加者を削除し、補欠者を繰り上げる
  def destroy_participant!(participant)
    ActiveRecord::Base.transaction do
      participant.destroy!
      promote_waitlist_user!
    end
  end

  # 補欠登録を削除する
  def destroy_waitlist!(waitlist)
    waitlist.destroy!
  end

  private

  def create_participant!
    EventParticipant.create!(user: user, event: event)
  end

  def create_waitlist!
    EventWaitlist.create!(user: user, event: event)
  end

  # キャンセル時に先頭の補欠ユーザーを昇格させる
  def promote_waitlist_user!
    return if event.full?

    promote_target = next_waitlist

    return unless promote_target

    promote_target.destroy!
    EventParticipant.create!(user: promote_target.user, event: event)
  end

  def next_waitlist
    EventWaitlist.where(event: event).order(:created_at).first
  end
end
