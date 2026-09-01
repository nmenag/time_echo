namespace :letters do
  desc "Deliver pending time capsules that are due today"
  task deliver: :environment do
    start_time = Time.current
    Rails.logger.info("[Rake letters:deliver] Starting daily letter delivery check...")

    queued_count = Letters::DispatchPendingService.call

    duration = (Time.current - start_time).round(2)
    Rails.logger.info("[Rake letters:deliver] Daily letter delivery check completed in #{duration}s (queued=#{queued_count}).")
  rescue => e
    Rails.logger.error("[Rake letters:deliver] Dispatch failed (#{e.class}): #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
    raise e
  end
end
