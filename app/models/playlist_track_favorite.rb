class PlaylistTrackFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :playlist_track
end
