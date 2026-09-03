module Letters
  class DispatchPendingJob < ApplicationJob
    queue_as :default

    def perform
      queued_count = Letters::DispatchPendingService.call
      Rails.logger.info("Letters::DispatchPendingJob completed (queued=#{queued_count})")
      queued_count
    end
  end
end
