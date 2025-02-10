class CreateEventWaitlists < ActiveRecord::Migration[8.0]
  def change
    create_table :event_waitlists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_waitlists, [:event_id, :user_id], unique: true
    add_index :event_waitlists, [:event_id, :created_at]
  end
end
