class AddPodcastsEnabledToRadios < ActiveRecord::Migration[4.2]
  def change
    add_column :radios, :podcasts_enabled, :boolean, default: false, null: false
  end
end
