class EventGroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    @event_groups = EventGroup.all
  end

  def show
    @event_group = event_group
    authorize @event_group
  end

  def new
    @event_group = EventGroup.new
    authorize @event_group
  end

  def create
    @event_group = EventGroup.new(event_group_params)
    authorize @event_group

    if @event_group.save
      redirect_to event_groups_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event_group = event_group
    authorize @event_group
  end

  def update
    @event_group = event_group
    authorize @event_group

    if @event_group.update(event_group_params)
      redirect_to event_group_path(@event_group), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize event_group

    event_group.destroy
    redirect_to event_groups_path, status: :see_other
  end

  private

  def event_group_params
    params.require(:event_group)
          .permit(:name, :description, :image)
          .merge(user_id: current_user.id)
  end

  def event_group
    @event_group ||= EventGroup.find(params[:id])
  end
end
