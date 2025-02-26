class EventParticipantsController < ApplicationController
  before_action :authenticate_user!

  def new
    @event_participant = EventParticipant.new
  end

  # 参加登録は current_user 前提（他人の登録はさせない）
  def create
    new_participant = EventParticipant.new(user: current_user, event: event)
    authorize new_participant

    service = EventRegistrationService.new(current_user, event)
    begin
      service.create_registration!
      flash[:notice] = "参加登録が完了しました。"
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.record.errors.full_messages.join(", ")
    end
    redirect_to event_path(event)
  end

  def destroy
    participant = EventParticipant.find(params[:id])
    authorize participant

    # TODO: 削除時にcurrent_userを渡す必要ないのでクラスを分けるなりする
    service = EventRegistrationService.new(current_user, event)
    begin
      service.destroy_participant!(participant)
      flash[:notice] = "参加登録を削除しました。"
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.record.errors.full_messages.join(", ")
    end
    redirect_to event_path(event)
  end

  private

  def event
    @event ||= Event.find(params[:event_id])
  end
end
