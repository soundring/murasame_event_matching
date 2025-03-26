require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:user) { create(:user) }
  let(:event_group) { create(:event_group, user: user) }

  let(:valid_image) do
    fixture_file_upload(
      Rails.root.join('spec/fixtures/test_image.jpg'),
      'image/jpeg'
    )
  end

  let(:invalid_file) do
    fixture_file_upload(
      Rails.root.join('spec/fixtures/test.txt'),
      'text/plain'
    )
  end

  let(:valid_event_params) do
    {
      title: 'New Event',
      event_start_at: Time.current + 1.day,
      event_end_at: Time.current + 2.days,
      recruitment_start_at: Time.current,
      recruitment_closed_at: Time.current + 1.day,
      max_participants: 10
    }
  end

  describe "認証関連" do
    context 'サインインしていない場合' do
      it 'イベント一覧ページにアクセスするとログインページにリダイレクトされること' do
        get event_group_events_path(event_group)
        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(302)
      end

      it 'イベント作成ページにアクセスするとログインページにリダイレクトされること' do
        get new_event_group_event_path(event_group)
        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(302)
      end
    end
  end

  context 'サインイン済みのユーザーとして' do
    before { sign_in user }

    describe "GET /index" do
      it 'イベント一覧が正常に表示されること' do
        get event_group_events_path(event_group)
        expect(response).to have_http_status(200)
      end
    end

    describe "GET /show" do
      context '存在するイベントの場合' do
        let!(:event) { create(:event, eventable: event_group) }

        it 'イベントの詳細が正常に表示されること' do
          get event_path(event)
          expect(response).to have_http_status(200)
        end
      end

      context '存在しないイベントの場合' do
        let(:non_existent_id) { Event.maximum(:id).to_i + 1 }

        it '404エラーが返されること' do
          get event_path(id: non_existent_id)
          expect(response).to have_http_status(404)
        end
      end
    end

    describe "POST /create" do
      context '基本的なイベント作成' do
        it '有効なパラメータで作成できること' do
          expect {
            post event_group_events_path(event_group), params: { event: valid_event_params }
          }.to change(Event, :count).by(1)

          expect(response).to redirect_to(event_group_events_path(event_group))
          follow_redirect!
          expect(response).to have_http_status(200)
        end

        it '無効なパラメータでは作成できないこと' do
          expect {
            post event_group_events_path(event_group), params: { event: valid_event_params.merge(title: '') }
          }.not_to change(Event, :count)

          expect(response).to have_http_status(422)
        end
      end

      context '画像アップロード機能' do
        context '有効な画像の場合' do
          it 'イベントが作成され画像が正常に添付されること' do
            expect {
              post event_group_events_path(event_group),
                params: { event: valid_event_params.merge(image: valid_image) }
            }.to change(Event, :count).by(1)

            event = Event.last
            expect(event.image).to be_attached
            expect(event.image.content_type).to eq('image/jpeg')
            expect(response).to redirect_to(event_group_events_path(event_group))
          end
        end

        context '無効なファイルの場合' do
          it 'バリデーションエラーとなり、イベントが作成されないこと' do
            expect {
              post event_group_events_path(event_group),
                params: { event: valid_event_params.merge(image: invalid_file) }
            }.not_to change(Event, :count)

            expect(response).to have_http_status(422)
          end
        end
      end
    end

    describe "PATCH /update" do
      let!(:event) { create(:event, eventable: event_group) }

      context '基本的な更新' do
        it '有効なパラメータで更新できること' do
          patch event_path(event), params: { event: { title: 'Updated Title' } }
          expect(event.reload.title).to eq('Updated Title')
          expect(response).to redirect_to(event)
        end

        it '無効なパラメータでは更新できないこと' do
          patch event_path(event), params: { event: { title: '' } }
          expect(response).to have_http_status(422)
        end
      end

      context '画像の更新' do
        it '新しい画像に更新できること' do
          patch event_path(event),
            params: { event: { image: valid_image } }

          event.reload
          expect(event.image).to be_attached
          expect(event.image.content_type).to eq('image/jpeg')
          expect(response).to redirect_to(event)
        end
      end
    end

    describe "DELETE /destroy" do
      let!(:event) { create(:event, eventable: event_group) }

      it 'イベントを削除できること' do
        expect {
          delete event_path(event)
        }.to change(Event, :count).by(-1)

        expect(response).to redirect_to(event_group_events_path(event_group))
        follow_redirect!
        expect(response).to have_http_status(200)
      end
    end
  end
end
