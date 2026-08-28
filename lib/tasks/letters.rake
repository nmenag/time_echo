namespace :letters do
  desc "Deliver pending time capsules that are due today"
  task deliver: :environment do
    Rails.logger.info("[Rake letters:deliver] Starting daily letter delivery check...")
    queued_count = Letters::DispatchPendingService.call
    Rails.logger.info("[Rake letters:deliver] Daily letter delivery check completed (queued=#{queued_count}).")
  end
end
