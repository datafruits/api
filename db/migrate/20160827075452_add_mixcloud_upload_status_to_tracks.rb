class AddMixcloudUploadStatusToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :mixcloud_upload_status, :integer, default: 0, null: false
  end
end