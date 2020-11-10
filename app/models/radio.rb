require_relative '../../lib/docker_wrapper'

class Radio < ActiveRecord::Base
  has_many :user_radios
  has_many :users, through: :user_radios
  has_many :scheduled_shows
  has_many :tracks
  has_many :labels
  has_many :playlists
  has_many :podcasts
  has_many :recordings
  has_many :listens
  has_many :host_applications
  has_many :blog_posts
  has_many :social_identities

  belongs_to :default_playlist, class_name: "Playlist"
  after_create :create_default_playlist

  validates :name, presence: true
  validates :name, uniqueness: true

  before_validation :copy_to_container_name

  scope :enabled, -> { where(enabled: true) }

  def djs
    self.users
  end

  def active_djs
    self.users.profile_published
  end

  def boot_radio
    RadioBooterWorker.perform_later self.id
  end

  def disable_radio
    RadioDisableWorker.perform_later self
  end

  def icecast_panel_url
    relay_url
  end

  def icecast_json
    "#{icecast_panel_url}status-json.xsl"
  end

  def mp3_url
    "#{self.icecast_panel_url}#{self.name}.mp3"
  end

  def relay_url
    "https://streampusher-relay.club/"
  end

  def relay_mp3_url
    "#{self.relay_url}#{self.container_name}.mp3"
  end

  def relay_m3u_url
    "#{relay_mp3_url}.m3u"
  end

  def relay_ogg_url
    "#{self.relay_url}#{self.name}.ogg"
  end

  def liquidsoap_container
    if !self.liquidsoap_container_id.blank?
      begin
        Docker::Container.get self.liquidsoap_container_id
      rescue
        nil
      end
    end
  end

  def virtual_host
    if ::Rails.env.production?
      "#{self.container_name}.streampusher.com"
    else
      "#{self.container_name}.streampusher.com:3000"
    end
  end

  def tracks_directory
    if ::Rails.env.production?
      dir = "/home/deploy/#{self.name}"
    else
      dir = "/tmp/#{self.name}".to_s
    end
    FileUtils.mkdir_p dir
    dir
  end

  def recordings_directory
    if ::Rails.env.production?
      dir = "/home/deploy/#{self.name}/recordings"
    else
      dir = "/tmp/#{self.name}/recordings".to_s
    end
    FileUtils.mkdir_p dir
    dir
  end

  def recording_files
    Dir["#{recordings_directory}/datafruits-*.mp3"]
  end

  def icecast_proxy_key
    "#{self.virtual_host}/icecast"
  end

  def liquidsoap_proxy_key
    "#{self.virtual_host}/liquidsoap"
  end

  def default_playlist_key
    "#{self.name}:default_playlist"
  end

  def listeners_key
    "#{self.name}:listeners"
  end

  def current_show_playing_key
    "#{self.name}:current_show_playing"
  end

  def set_current_show_playing show_id
    Redis.current.set "#{self.name}:current_show_playing", show_id
  end

  def current_show_playing
    Redis.current.get current_show_playing_key
  end

  def current_show_playing?
    !current_show_playing.blank?
  end

  def current_track_playing_key
    "#{self.name}:current_track_playing"
  end

  def set_current_track_playing track_id
    Redis.current.set "#{self.name}:current_track_playing", track_id
  end

  def current_track_playing
    Redis.current.get current_track_playing_key
  end

  def liquidsoap_harbor_port
    self.port_number
  end

  def current_scheduled_show now=Time.now
    self.scheduled_shows.where("start_at <= ? AND end_at >= ?", now, now).first
  end

  def next_scheduled_show now=Time.now
    self.scheduled_shows.where("start_at >= ?", now).order("start_at ASC").first
  end

  def disk_usage
    self.tracks.pluck(:filesize).sum
  end

  def liquidsoap_socket_path
    "#{tracks_directory}/liquidsoap.sock"
  end

  private
  def copy_to_container_name
    if self.name.present?
      self.container_name = self.name.gsub(/[^a-zA-Z0-9_]/, '')
    end
  end

  def create_default_playlist
    self.playlists.create name: "default"
  end
end
