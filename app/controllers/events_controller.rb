class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize Event
    @events = fetch_events
  end

  def show
    @event = event_with_participants
    authorize @event
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
      redirect_to event, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if event.destroy
      redirect_to polymorphic_path([event.eventable, :events]), status: :see_other
    else
      redirect_to event, status: :see_other
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
    base_query = eventable.events.with_attached_image.includes(:event_participants, :event_waitlists)

    if current_user.administered_groups.exists?(eventable.id)
      base_query
    else
      base_query.published
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
    @event ||= Event.with_attached_image.find(params[:id])
  end

  def event_with_participants
    @event_with_participants ||= Event.includes(event_participants: :user, event_waitlists: :user)
                                     .with_attached_image
                                     .find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title,
      :subtitle,
      :description,
      :image,
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
