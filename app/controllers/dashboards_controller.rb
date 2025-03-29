class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @participating_events = current_user.participating_events
                                      .includes(:eventable)
                                      .where(status: 'published')
                                      .where('event_start_at >= ?', Date.current)
                                      .order(event_start_at: :asc)
                                      .limit(5)

    @administered_groups = current_user.administered_groups
                                     .includes(:events)
                                     .order(created_at: :asc)
                                     .limit(5)

    # TODO: ユーザーイベントも含める
    @administered_events = Event.preload(:eventable)
                            .where(eventable_type: 'EventGroup',
                                   eventable_id: current_user.administered_group_ids)
                            .where('event_start_at >= ?', Date.current)
                            .order(event_start_at: :asc)
                            .limit(5)
  end
end
