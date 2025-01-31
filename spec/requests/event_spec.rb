require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:user) { create(:user) }
  let(:event_group) { create(:event_group) }

  before { sign_in user }

  describe "GET /index" do
    context 'サインインしてない場合' do
      before { sign_out user }

      it 'リダイレクトすること' do
        get event_group_events_path(event_group)
        expect(response).to have_http_status(302)
      end
    end

    context 'サインインしている場合' do
      context 'EventGroupに紐付いている場合' do
        let!(:event) { create(:event, eventable: event_group) }

        it '200 OKが返されること' do
          get event_group_events_path(event_group)
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe "GET /show" do
    let!(:event) { create(:event, eventable: event_group) }

    it '200 OKが返されること' do
      get event_path(event)
      expect(response).to have_http_status(200)
    end

    context '存在しないイベントの場合' do
      let(:non_existent_id) { Event.maximum(:id).to_i + 1 }

      it '404 Not Foundが返されること' do
        get event_path(id: non_existent_id)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "GET /new" do
    it '200 OKが返されること' do
      get new_event_group_event_path(event_group)
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /create" do
    let(:event_params) {
      {
        title: 'New Event',
        event_start_at: Time.now + 1.day,
        event_end_at: Time.now + 2.days,
        recruitment_start_at: Time.now,
        recruitment_closed_at: Time.now + 1.day
      }
    }

    context 'EventGroupに紐付いている場合' do
      it '新しいイベントを作成してリダイレクトされること' do
        expect {
          post event_group_events_path(event_group), params: { event: event_params }
        }.to change(Event, :count).by(1)
        expect(response).to redirect_to(event_group_events_path(event_group))
      end
    end

    context '無効なパラメータの場合' do
      let(:invalid_params) { { event: { title: '' } } }

      it 'イベント作成に失敗し作成画面をされること' do
        expect {
          post event_group_events_path(event_group), params: invalid_params
        }.not_to change(Event, :count)
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "GET /edit" do
    context 'EventGroupに紐付いている場合' do
      let!(:event) { create(:event, eventable: event_group) }

      it '200 OKが返されること' do
        get edit_event_path(event)
        expect(response).to have_http_status(200)
      end
    end

    context '存在しないイベントの場合' do
      let(:non_existent_id) { Event.maximum(:id).to_i + 1 }

      it '404 Not Foundが返されること' do
        get edit_event_path(id: non_existent_id)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH /update" do
    let!(:event) { create(:event, eventable: event_group) }
    let(:valid_params) { { event: { title: 'Updated Title' } } }
    let(:invalid_params) { { event: { title: '' } } }

    context '有効なパラメータの場合' do
      it 'イベントを更新しリダイレクトする' do
        patch event_path(event), params: valid_params
        expect(event.reload.title).to eq('Updated Title')
        expect(response).to redirect_to(event)
      end
    end

    context '無効なパラメータの場合' do
      it '更新に失敗し編集画面が再表示されること' do
        patch event_path(event), params: invalid_params
        expect(response).to have_http_status(422)
      end
    end

    context '存在しないイベントの場合' do
      let(:non_existent_id) { Event.maximum(:id).to_i + 1 }

      it '404 Not Foundが返されること' do
        patch event_path(id: non_existent_id)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "DELETE /destroy" do
    context 'EventGroupに紐付いている場合' do
      let!(:event) { create(:event, eventable: event_group) }

      it 'イベントを削除しイベント一覧にリダイレクトされること' do
        expect {
          delete event_path(event)
        }.to change(Event, :count).by(-1)
        expect(response).to redirect_to(event_group_events_path(event_group))
      end
    end

    context '存在しないイベントの場合' do
      let(:non_existent_id) { Event.maximum(:id).to_i + 1 }

      it '404 Not Foundが返されること' do
        delete event_path(id: non_existent_id)
        expect(response).to have_http_status(404)
      end
    end
  end
end
