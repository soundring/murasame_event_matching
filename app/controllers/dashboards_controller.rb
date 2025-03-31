class DashboardsController < ApplicationController
  before_action :authenticate_user!

  # TODO: カウントに関しては、counter_cacheを使うようにする
  def show
    @participating_events = current_user.participating_events
                                      .with_attached_image
                                      .includes(:eventable, eventable: :events)
                                      .published
                                      .now_than_after
                                      .order(event_start_at: :asc)
                                      .limit(5)

    @administered_groups = current_user.administered_groups
                                     .with_attached_image
                                     .includes(:events)
                                     .order(created_at: :asc)
                                     .limit(5)

    # TODO: ユーザーイベントも含める
    @administered_events = Event.with_attached_image
                            .preload(:eventable)
                            .where(eventable_type: 'EventGroup',
                                   eventable_id: current_user.administered_group_ids)
                            .now_than_after
                            .order(event_start_at: :asc)
                            .limit(5)
  end
end
