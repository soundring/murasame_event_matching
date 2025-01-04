class CreateEventGroupAdmins < ActiveRecord::Migration[8.0]
  def change
    create_table :event_group_admins do |t|
      t.references :event_group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_group_admins, [:event_group_id, :user_id], unique: true
  end
end
