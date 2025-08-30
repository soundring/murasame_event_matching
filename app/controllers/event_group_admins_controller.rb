class EventGroupAdminsController < ApplicationController
  before_action :authenticate_user!

  def index
    @event_group_admins = event_group.event_group_admins
    authorize @event_group_admins
  end

  def new
    @event_group = event_group
    @event_group_admin = @event_group.event_group_admins.new
    authorize @event_group_admin
  end

  def create
    @event_group_admin = EventGroupAdmin.new(event_group_admin_params)
    authorize @event_group_admin

    if @event_group_admin.save
    else
      flash[:alert] = '登録に失敗しました。'
      redirect_to event_group_event_group_admins_path(@event_group_admin.event_group)
    end
  end

  def destroy
    authorize event_group_admin

    event_group = event_group_admin.event_group
    target_user = event_group_admin.user

    if event_group.owner?(target_user)
      flash[:alert] = 'オーナーは削除できません。'
      redirect_to event_group_event_group_admins_path(event_group), status: :see_other
    else
      if event_group_admin.destroy
      else
        flash[:alert] = '削除に失敗しました。'
        redirect_to event_group_event_group_admins_path(event_group), status: :see_other
      end
    end
  end

  private

  def event_group_admin_params
    params.require(:event_group_admin)
          .permit(:user_id, :event_group_id)
  end

  def event_group
    @event_group ||= EventGroup.find(params[:event_group_id])
  end

  def event_group_admin
    @event_group_admin ||= EventGroupAdmin.find(params[:id])
  end
end
