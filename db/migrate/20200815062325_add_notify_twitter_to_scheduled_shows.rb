class AddNotifyTwitterToScheduledShows < ActiveRecord::Migration[5.0]
  def change
    add_column :scheduled_shows, :notify_twitter, :boolean, default: false, null: false
  end
end
