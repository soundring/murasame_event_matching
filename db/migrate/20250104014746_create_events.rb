class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.string :subtitle # イベントのサブタイトル
      t.text :description # イベント説明
      t.string :image_url # イベント画像URL
      t.datetime :event_start_at  # イベント開始日時
      t.datetime :event_end_at    # イベント終了日時
      t.datetime :recruitment_start_at    # 募集開始日時
      t.datetime :recruitment_closed_at   # 募集終了日時
      t.string :location # 開催場所
      t.integer :max_participants # 定員
      t.integer :status, null: false, default: 0 # 開催状況

      t.references :eventable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :events, :title
    add_index :events, :status
    add_index :events, :location
    add_index :events, [:eventable_type, :eventable_id]
    add_index :events, :event_start_at
    add_index :events, :recruitment_start_at
  end
end
