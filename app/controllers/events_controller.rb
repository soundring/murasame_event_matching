class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = eventable.events
  end

  def show
    event
  end

  def new
    @event = eventable.events.new
  end

  def create
    @event = eventable.events.new(event_params)

    if @event.save
      redirect_to polymorphic_path([@event.eventable, :events])
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    event
  end

  def update
    if event.update(event_params)
      redirect_to event
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if event.destroy
      redirect_to polymorphic_path([event.eventable, :events])
    else
      redirect_to event
    end
  end

  private

  def eventable
    # TODO: request.path_parameters から eventable を判定する(見辛いからスキップした)
    @eventable ||= begin
      if params[:event_group_id]
        EventGroup.find(params[:event_group_id])
      else
        User.find(params[:user_id])
      end
    end
  end

  def event
    @event ||= Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title,
      :subtitle,
      :description,
      :image_url,
      :event_start_at,
      :event_end_at,
      :recruitment_start_at,
      :recruitment_closed_at,
      :location,
      :max_participants,
      :status
    )
  end
end
