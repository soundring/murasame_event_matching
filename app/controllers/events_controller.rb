class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize Event
    @events = fetch_events
  end

  def show
    authorize event
  end

  def new
    @event = eventable.events.new
    authorize @event
  end

  def create
    @event = eventable.events.new(event_params)
    authorize @event

    if @event.save
      redirect_to polymorphic_path([@event.eventable, :events])
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize event
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

  def fetch_events
    if eventable.is_a?(EventGroup)
      fetch_group_events
    else
      # TODO: 個人イベントの場合の処理を追加する
      # コントローラー分けてもいいのかもしれない
    end
  end

  def fetch_group_events
    if current_user.administered_groups.exists?(eventable.id)
      eventable.events
    else
      eventable.events.published
    end
  end

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
