class RenameAndChangeProfilePictureUrlToAvatarUrl < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :profile_picture_url, :avatar_url

    # URLが長い場合を考慮してtext型に変更している
    reversible do |dir|
      dir.up   { change_column :users, :avatar_url, :text }
      dir.down { change_column :users, :avatar_url, :string }
    end
  end
end
