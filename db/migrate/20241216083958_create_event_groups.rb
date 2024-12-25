class CreateEventGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :event_groups do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.text :image_url, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_groups, :name
  end
end
