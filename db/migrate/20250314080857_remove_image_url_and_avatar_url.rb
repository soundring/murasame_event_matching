class RemoveImageUrlAndAvatarUrl < ActiveRecord::Migration[8.0]
  def change
    remove_column :event_groups, :image_url, :text
    remove_column :events, :image_url, :string
    remove_column :users, :avatar_url, :text
  end
end
