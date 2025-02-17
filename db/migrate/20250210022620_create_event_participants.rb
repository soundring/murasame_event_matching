class CreateEventParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :event_participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_participants, [:event_id, :user_id], unique: true
  end
end
