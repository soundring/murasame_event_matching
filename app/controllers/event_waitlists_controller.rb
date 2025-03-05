class EventWaitlistsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    waitlist = EventWaitlist.find(params[:id])
    authorize waitlist

    # TODO: 削除時にcurrent_userを渡す必要ないのでクラスを分けるなりする
    service = EventRegistrationService.new(current_user, event)
    service.destroy_waitlist!(waitlist)
    flash[:notice] = "補欠登録を削除しました。"
    redirect_to event_path(event), status: :see_other
  end

  private

  def event
    @event ||= Event.find(params[:event_id])
  end
end
