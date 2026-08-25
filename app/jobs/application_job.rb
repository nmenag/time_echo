class ApplicationJob < ActiveJob::Base
  around_perform :instrument_perform

  private

  def instrument_perform
    cron_key = GoodJob::CurrentThread.cron_key
    tags = [ "job:#{self.class.name}", "job_id:#{job_id}", "queue:#{queue_name}" ]
    tags << "cron:#{cron_key}" if cron_key

    Rails.logger.tagged(*tags) do
      start_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Rails.logger.info("#{self.class.name} started")

      yield

      finished_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      duration_ms = ((finished_at - start_at) * 1000).round(1)
      Rails.logger.info("#{self.class.name} finished duration_ms=#{duration_ms}")
    end
  rescue => e
    Rails.logger.error("#{self.class.name} failed error=#{e.class}: #{e.message}")
    raise
  end
end
