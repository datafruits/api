class CreateUserPlaylistTrackFavorites < ActiveRecord::Migration[5.0]
  def change
    create_table :playlist_track_favorites do |t|
      t.references :user, null: false
      t.references :playlist_track, null: false

      t.timestamps
    end
  end
end
