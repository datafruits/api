require_relative "../../lib/time_utils"

class ScheduledShow < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :radio
  belongs_to :dj, class_name: "User"
  belongs_to :playlist
  belongs_to :recurrant_original, class_name: "ScheduledShow"
  has_attached_file :image, styles: { :thumb => "x300" },
    path: ":attachment/:style/:basename.:extension"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  has_many :scheduled_show_labels, dependent: :destroy
  has_many :labels, through: :scheduled_show_labels

  has_many :tracks
  has_many :scheduled_show_performers, class_name: "::ScheduledShowPerformer", dependent: :destroy
  has_many :performers, through: :scheduled_show_performers, source: :user
  accepts_nested_attributes_for :scheduled_show_performers

  validates_presence_of :start_at, :end_at, :playlist_id, :title
  validates :description, length: { maximum: 10000 }

  validate :start_at_cannot_be_in_the_past, on: :create
  validate :end_at_cannot_be_in_the_past, on: :create
  validate :end_at_cannot_be_before_start_at, on: :create

  alias_attribute :start, :start_at
  alias_attribute :end, :end_at
  attr_accessor :update_all_recurrences, :destroy_recurrences

  before_save :update_recurring_intervals # probably not correct
  after_create :save_recurrences_in_background, if: :recurring?
  after_update :update_recurrences_in_background, if: :recurring_or_recurrence?
  after_update :save_recurrences_in_background, if: :recurring_interval_changed?
  before_destroy :maybe_destroy_recurrences

  after_save :schedule_tweet, if: :start_at_changed?

  before_save :ensure_time_zone

  enum recurring_interval: [:not_recurring, :day, :week, :month, :year, :biweek]

  def self.recurring_interval_attributes_for_select
    recurring_intervals.map do |recurring_interval, _|
      [I18n.t("activerecord.attributes.#{model_name.i18n_key}.recurring_intervals.#{recurring_interval}"), recurring_interval]
    end
  end

  def self.update_all_recurrences_attributes_for_select
    [
      [I18n.t("activerecord.attributes.#{model_name.i18n_key}.update_all_recurrences"), true],
      [I18n.t("activerecord.attributes.#{model_name.i18n_key}.update_only_this_recurrence"), false]
    ]
  end

  # TODO
  # validate :time_is_in_15_min_intervals
  #
  def playlist_or_default
    # playlist presence is validated, but it might be deleted
    # and we can't add dependant destroy
    self.playlist || self.radio.default_playlist
  end

  def image_url
    self.image.url(:original)
  end

  def thumb_image_url
    self.image.url(:thumb)
  end

  def schedule_cannot_conflict
    self.radio.scheduled_shows.where.not(id: id).each do |show|
      if end_at > show.start_at && start_at < show.end_at
        errors.add(:time, " conflict detected with show '#{show.user.username} - #{show.title}'. Please choose a different time.")
      end
    end
  end

  def recurrences
    self.class.where(recurrant_original_id: self.id)
  end

  def recurring?
    !self.not_recurring? && !self.recurrence?
  end

  def recurring_or_recurrence?
    recurring? || self.recurrence?
  end

  def human_readable_recurring
    case self.recurring_interval.to_sym
    when :day
      "daily"
    when :week
      "weekly"
    when :biweek
      "bi-weekly"
    when :month
      "monthly"
    when :year
      "yearly"
    end
  end

  def save_recurrences_in_background
    SaveRecurringShowsWorker.perform_later self.id
  end

  def update_recurrences_in_background
    if update_all_recurrences?
      UpdateRecurringShowsWorker.perform_later self.id
    end
  end

  def do_destroy_recurrences
    recurrences_to_update.destroy_all
  end

  def save_recurrences
    if recurring?
      start_and_end_recurrences.each do |s,e|
        scheduled_show = self.dup
        scheduled_show.recurring_interval = self.recurring_interval
        scheduled_show.recurrence = true
        scheduled_show.recurrant_original_id = self.id
        scheduled_show.start_at = DateTime.new s.year, s.month, s.day, self.start_at.hour, self.start_at.min, self.start_at.sec, self.start_at.zone
        scheduled_show.end_at = DateTime.new e.year, e.month, e.day, self.end_at.hour, self.end_at.min, self.end_at.sec, self.end_at.zone
        scheduled_show.slug = nil
        next if scheduled_show.start_at == self.start_at
        scheduled_show.save!
      end
    end
  end

  def update_recurrences
    recurrences_to_update.each do |r|
      r.attributes = self.attributes.except("id","created_at","updated_at","start_at","end_at","recurring_interval","recurrence", "recurrant_original_id", "slug")
      new_start_at = DateTime.new r.start_at.year, r.start_at.month, r.start_at.day, self.start_at.hour, self.start_at.min, self.start_at.sec, self.start_at.zone
      r.start_at = new_start_at
      new_end_at = DateTime.new r.end_at.year, r.end_at.month, r.end_at.day, self.end_at.hour, self.end_at.min, self.end_at.sec, self.end_at.zone
      r.end_at = new_end_at
      r.update_all_recurrences = false
      r.save!
    end
  end

  def slug_candidates
    [
      [:title, :id]
    ]
  end

  def fall_forward_recurrances_for_dst!
    recurrences_to_update.each do |r|
      r.update start_at: r.start_at+1.hour, end_at: r.end_at+1.hour
    end
  end

  def fall_back_recurrances_for_dst!
    recurrences_to_update.each do |r|
      r.update start_at: r.start_at-1.hour, end_at: r.end_at-1.hour
    end
  end

  private
  def recurring_interval_changed?
    self.changes.has_key? "recurring_interval"
  end

  def maybe_destroy_recurrences
    id = self.recurrant_original_id || self.id
    if destroy_recurrences
      DestroyRecurringShowsWorker.perform_later id
    end
  end

  def ensure_time_zone
    unless self.time_zone.blank?
      # only take local times as input
      unless self.start_at.utc?
        self.start_at = ActiveSupport::TimeZone.new(self.time_zone).local_to_utc(self.start_at)
      end
      unless self.end_at.utc?
        self.end_at = ActiveSupport::TimeZone.new(self.time_zone).local_to_utc(self.end_at)
      end
    end
  end

  def start_at_cannot_be_in_the_past
    if start_at < Time.now
      errors.add(:start_at, "cannot be in the past")
    end
  end

  def end_at_cannot_be_in_the_past
    if end_at < Time.now
      errors.add(:end_at, "cannot be in the past")
    end
  end

  def end_at_cannot_be_before_start_at
    if end_at < start_at
      errors.add(:end_at, "cannot be before start at")
    end
  end

  def start_and_end_recurrences options={}
    starts = recurrence_times(options.merge(starts: self.start))
    ends = recurrence_times(options.merge(starts: self.end))
    if starts.length != ends.length
      while starts.length != ends.length
        if starts.length > ends.length
          starts.pop
        else
          ends.pop
        end
      end
    end
    starts.zip(ends)
  end

  def recurrence_times options={}
    options = {:every => self.recurring_interval}.merge(options)
    options[:on] = case options[:every]
    when 'year'
      [options[:starts].month, options[:starts].day]
    when 'week', 'biweek'
      options[:starts].strftime('%A').downcase.to_sym
    when 'day'
      options[:starts].day
    when 'month'
      TimeUtils.week_of_month_for_date(self.start_at)
    end
    if options[:every] == "month"
      options[:weekday] = self.start_at.strftime("%A").downcase.to_sym
    elsif options[:every] == "biweek"
      options[:interval] = 2
      options[:every] = "week"
    end
    Recurrence.new(options).events
  end

  def update_recurring_intervals
    # if the recurring interval was changed, we need to destroy all the recurring shows and call save_recurrences again
    if self.changes.include?("recurring_interval") && !self.new_record?
      self.recurrences.destroy_all
      # save_recurrences_in_background
    end
  end

  def recurrences_to_update
    if !is_original_recurrant?
      self.radio.scheduled_shows.where(recurrant_original_id: self.recurrant_original_id).where("start_at > (?)", Time.now)
    else # this is the original recurring show!
      recurrences.where("start_at > (?)", Time.now)
    end
  end

  def update_all_recurrences?
    ActiveModel::Type::Boolean.new.cast update_all_recurrences
  end

  def is_original_recurrant?
    !self.recurrant_original_id.present?
  end

  def schedule_tweet
    if self.notify_twitter?
      ScheduledShowNotificationWorker.perform_later self.id
    end
  end
end
