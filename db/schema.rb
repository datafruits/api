# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200815062325) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blog_post_bodies", force: :cascade do |t|
    t.integer  "language",     default: 0,     null: false
    t.integer  "blog_post_id",                 null: false
    t.string   "title",                        null: false
    t.text     "body"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "published",    default: false, null: false
    t.index ["blog_post_id"], name: "index_blog_post_bodies_on_blog_post_id", using: :btree
  end

  create_table "blog_post_images", force: :cascade do |t|
    t.integer  "blog_post_body_id"
    t.string   "image_file_name"
    t.integer  "filesize"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["blog_post_body_id"], name: "index_blog_post_images_on_blog_post_body_id", using: :btree
  end

  create_table "blog_posts", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.integer  "radio_id",     null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "published_at"
    t.index ["radio_id"], name: "index_blog_posts_on_radio_id", using: :btree
    t.index ["user_id"], name: "index_blog_posts_on_user_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "host_applications", force: :cascade do |t|
    t.integer  "radio_id",                      null: false
    t.string   "email",                         null: false
    t.string   "username",                      null: false
    t.string   "link",                          null: false
    t.integer  "interval",      default: 0,     null: false
    t.text     "desired_time",                  null: false
    t.string   "time_zone",                     null: false
    t.string   "other_comment"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "approved",      default: false, null: false
    t.string   "homepage_url"
    t.index ["radio_id"], name: "index_host_applications_on_radio_id", using: :btree
  end

  create_table "labels", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "radio_id",   null: false
    t.index ["radio_id"], name: "index_labels_on_radio_id", using: :btree
  end

  create_table "links", force: :cascade do |t|
    t.string   "url"
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_links_on_user_id", using: :btree
  end

  create_table "listens", force: :cascade do |t|
    t.integer  "radio_id"
    t.string   "ip_address",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.float    "lat"
    t.float    "lon"
    t.integer  "icecast_listener_id",             null: false
    t.string   "user_agent"
    t.string   "referer"
    t.string   "country"
    t.string   "address"
    t.index ["radio_id"], name: "index_listens_on_radio_id", using: :btree
  end

  create_table "plans", force: :cascade do |t|
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       default: "", null: false
  end

  create_table "playlist_tracks", force: :cascade do |t|
    t.integer  "track_id",               null: false
    t.integer  "playlist_id",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.datetime "podcast_published_date"
    t.index ["playlist_id"], name: "index_playlist_tracks_on_playlist_id", using: :btree
    t.index ["track_id"], name: "index_playlist_tracks_on_track_id", using: :btree
  end

  create_table "playlists", force: :cascade do |t|
    t.integer  "radio_id",                                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                                       limit: 255
    t.integer  "interpolated_playlist_id"
    t.integer  "interpolated_playlist_track_play_count"
    t.integer  "interpolated_playlist_track_interval_count"
    t.boolean  "interpolated_playlist_enabled",                          default: false, null: false
    t.boolean  "no_cue_out",                                             default: true,  null: false
    t.boolean  "shuffle",                                                default: false, null: false
    t.integer  "user_id"
    t.boolean  "repeat",                                                 default: false, null: false
    t.index ["interpolated_playlist_id"], name: "index_playlists_on_interpolated_playlist_id", using: :btree
    t.index ["radio_id"], name: "index_playlists_on_radio_id", using: :btree
    t.index ["user_id"], name: "index_playlists_on_user_id", using: :btree
  end

  create_table "podcasts", force: :cascade do |t|
    t.integer  "radio_id",                        null: false
    t.string   "title"
    t.string   "link"
    t.string   "description"
    t.datetime "last_build_date"
    t.string   "itunes_summary"
    t.string   "itunes_name"
    t.string   "itunes_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",               default: "", null: false
    t.integer  "playlist_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "extra_tags"
    t.index ["playlist_id"], name: "index_podcasts_on_playlist_id", using: :btree
    t.index ["radio_id"], name: "index_podcasts_on_radio_id", using: :btree
  end

  create_table "radios", force: :cascade do |t|
    t.string   "icecast_container_id",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                            limit: 255, default: "",    null: false
    t.string   "liquidsoap_container_id",         limit: 255
    t.integer  "default_playlist_id"
    t.boolean  "enabled",                                     default: true,  null: false
    t.boolean  "vj_enabled",                                  default: false, null: false
    t.boolean  "podcasts_enabled",                            default: false, null: false
    t.boolean  "stats_enabled",                               default: false, null: false
    t.boolean  "social_identities_enabled",                   default: false, null: false
    t.string   "tunein_partner_id"
    t.string   "tunein_partner_key"
    t.string   "tunein_station_id"
    t.boolean  "tunein_metadata_updates_enabled",             default: false, null: false
    t.string   "container_name",                                              null: false
    t.boolean  "schedule_monitor_enabled",                    default: false, null: false
    t.string   "show_share_url"
    t.integer  "port_number"
    t.index ["default_playlist_id"], name: "index_radios_on_default_playlist_id", using: :btree
  end

  create_table "recordings", force: :cascade do |t|
    t.integer  "radio_id",                      null: false
    t.integer  "dj_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.integer  "processing_status", default: 0, null: false
    t.integer  "track_id"
    t.datetime "file_created_at"
    t.index ["dj_id"], name: "index_recordings_on_dj_id", using: :btree
    t.index ["radio_id"], name: "index_recordings_on_radio_id", using: :btree
    t.index ["track_id"], name: "index_recordings_on_track_id", using: :btree
  end

  create_table "scheduled_show_labels", force: :cascade do |t|
    t.integer  "label_id"
    t.integer  "scheduled_show_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["label_id"], name: "index_scheduled_show_labels_on_label_id", using: :btree
    t.index ["scheduled_show_id", "label_id"], name: "index_scheduled_show_labels_on_scheduled_show_id_and_label_id", unique: true, using: :btree
    t.index ["scheduled_show_id"], name: "index_scheduled_show_labels_on_scheduled_show_id", using: :btree
  end

  create_table "scheduled_show_performers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "scheduled_show_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["scheduled_show_id", "user_id"], name: "ssp_ssid_uid", using: :btree
    t.index ["scheduled_show_id"], name: "index_scheduled_show_performers_on_scheduled_show_id", using: :btree
    t.index ["user_id", "scheduled_show_id"], name: "index_scheduled_show_performers_on_uid_and_ssid", unique: true, using: :btree
    t.index ["user_id"], name: "index_scheduled_show_performers_on_user_id", using: :btree
  end

  create_table "scheduled_shows", force: :cascade do |t|
    t.integer  "radio_id",                              null: false
    t.datetime "start_at",                              null: false
    t.datetime "end_at",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "recurring_interval",    default: 0,     null: false
    t.boolean  "recurrence",            default: false, null: false
    t.integer  "recurrant_original_id"
    t.integer  "playlist_id"
    t.integer  "dj_id"
    t.string   "title"
    t.string   "time_zone"
    t.string   "slug"
    t.boolean  "notify_twitter",        default: false, null: false
    t.index ["dj_id"], name: "index_scheduled_shows_on_dj_id", using: :btree
    t.index ["playlist_id"], name: "index_scheduled_shows_on_playlist_id", using: :btree
    t.index ["radio_id"], name: "index_scheduled_shows_on_radio_id", using: :btree
    t.index ["recurrant_original_id"], name: "index_scheduled_shows_on_recurrant_original_id", using: :btree
    t.index ["slug", "id"], name: "index_scheduled_shows_on_slug_and_id", unique: true, using: :btree
  end

  create_table "shows", force: :cascade do |t|
    t.string   "title",              limit: 255, default: "", null: false
    t.integer  "dj_id",                                       null: false
    t.integer  "radio_id",                                    null: false
    t.text     "description",                    default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "playlist_id"
    t.string   "color"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "social_identities", force: :cascade do |t|
    t.string   "uid",          default: "", null: false
    t.string   "provider",     default: "", null: false
    t.integer  "user_id",                   null: false
    t.string   "token"
    t.string   "string"
    t.string   "token_secret"
    t.string   "name",         default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["user_id"], name: "index_social_identities_on_user_id", using: :btree
  end

  create_table "track_labels", force: :cascade do |t|
    t.integer  "label_id",   null: false
    t.integer  "track_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_track_labels_on_label_id", using: :btree
    t.index ["track_id", "label_id"], name: "index_track_labels_on_track_id_and_label_id", unique: true, using: :btree
    t.index ["track_id"], name: "index_track_labels_on_track_id", using: :btree
  end

  create_table "tracks", force: :cascade do |t|
    t.string   "audio_file_name",          limit: 255
    t.integer  "radio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",                          default: "", null: false
    t.string   "artist"
    t.string   "title"
    t.string   "album"
    t.integer  "year"
    t.integer  "track"
    t.integer  "filesize",                             default: 0,  null: false
    t.integer  "tag_processing_status",                default: 0,  null: false
    t.integer  "length"
    t.string   "artwork_file_name"
    t.string   "artwork_content_type"
    t.integer  "artwork_file_size"
    t.datetime "artwork_updated_at"
    t.integer  "mixcloud_upload_status",               default: 0,  null: false
    t.string   "mixcloud_key"
    t.integer  "soundcloud_upload_status",             default: 0,  null: false
    t.string   "soundcloud_key"
    t.integer  "uploaded_by_id"
    t.integer  "scheduled_show_id"
    t.index ["audio_file_name", "id"], name: "index_tracks_on_audio_file_name_and_id", unique: true, using: :btree
    t.index ["radio_id"], name: "index_tracks_on_radio_id", using: :btree
    t.index ["scheduled_show_id"], name: "index_tracks_on_scheduled_show_id", using: :btree
    t.index ["uploaded_by_id"], name: "index_tracks_on_uploaded_by_id", using: :btree
  end

  create_table "user_radios", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "radio_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["radio_id"], name: "index_user_radios_on_radio_id", using: :btree
    t.index ["user_id", "radio_id"], name: "index_user_radios_on_user_id_and_radio_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_user_radios_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   limit: 255
    t.string   "username",               limit: 255, default: "",    null: false
    t.string   "time_zone"
    t.string   "display_name",                       default: "",    null: false
    t.datetime "deleted_at"
    t.boolean  "enabled",                            default: true,  null: false
    t.string   "referer"
    t.text     "bio"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.bigint   "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "profile_publish",                    default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "blog_post_images", "blog_post_bodies"
  add_foreign_key "scheduled_show_labels", "labels"
  add_foreign_key "scheduled_show_labels", "scheduled_shows"
end
