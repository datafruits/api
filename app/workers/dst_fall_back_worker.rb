class DstFallBackWorker < ActiveJob::Base
  queue_as :default

  def perform radio
    radio.scheduled_shows.
      where(recurrant_original_id: nil).where.not(recurring_interval: "not_recurring").
      find_each do |show|
      show.fall_back_recurrances_for_dst!
    end
  end
end
