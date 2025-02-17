class EventRegistrationService
  private attr_reader :user, :event

  def initialize(user, event)
    @user = user
    @event = event
  end

  # 参加 or 補欠登録
  def create_registration!
    ActiveRecord::Base.transaction do
      if event.full?
        create_waitlist!
      else
        create_participant!
      end
    end
  end

  # 参加を削除して補欠繰り上げ
  def destroy_participant!(participant)
    ActiveRecord::Base.transaction do
      participant.destroy!
      promote_waitlist_user!
    end
  end

  # 補欠を削除
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

    next_waitlist_user = EventWaitlist.where(event: event).order(:created_at).first
    return unless next_waitlist_user

    ActiveRecord::Base.transaction do
      next_waitlist_user.destroy!
      EventParticipant.create!(user: next_waitlist_user.user, event: event)
    end
  end
end
