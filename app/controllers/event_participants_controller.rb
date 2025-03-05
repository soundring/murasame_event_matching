class EventParticipantsController < ApplicationController
  before_action :authenticate_user!

  def new
    @event = Event.find(params[:event_id])
    @event_participant = EventParticipant.new
  end

  # 参加登録は current_user 前提（他人の登録はさせない）
  def create
    event
    @event_participant = EventParticipant.new(user: current_user, event: event)
    authorize @event_participant

    service = EventRegistrationService.new(current_user, event)
    begin
      service.create_registration!
      redirect_to event_path(event)
    rescue ActiveRecord::RecordInvalid => e
      @event_participant = e.record
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    participant = EventParticipant.find(params[:id])
    authorize participant

    # TODO: 削除時にcurrent_userを渡す必要ないのでクラスを分けるなりする
    service = EventRegistrationService.new(current_user, event)
    begin
      service.destroy_participant!(participant)
    rescue ActiveRecord::RecordInvalid => e
    end
    redirect_to event_path(event), status: :see_other
  end

  private

  def event
    @event ||= Event.find(params[:event_id])
  end
end
