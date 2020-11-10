class ScheduledShowNotification
  def self.perform scheduled_show
    ScheduledShowNotification::Twitter.perform(scheduled_show)
  end
end
