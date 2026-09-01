module Letters
  class DeliverLetterJob < ApplicationJob
    queue_as :mailers

    TRANSIENT_ERRORS = [
      Net::OpenTimeout,
      Net::ReadTimeout,
      Timeout::Error,
      Errno::ECONNRESET,
      Errno::ECONNREFUSED,
      Errno::ETIMEDOUT,
      SocketError
    ].freeze

    retry_on(*TRANSIENT_ERRORS, wait: :polynomially_longer, attempts: 5) do |job, error|
      letter_id = job.arguments.first
      Letter.find_by(id: letter_id)&.update(status: "failed")
      Analytics::TrackEventService.call("delivery_failed", {
        letter_id: letter_id,
        error: "Exhausted retries (#{error.class}): #{error.message}"
      })
    end

    discard_on ActiveJob::DeserializationError do |job, error|
      Rails.logger.error("#{job.class} discarded — letter record missing: #{error.message}")
    end

    def perform(letter_id)
      letter = Letter.find(letter_id)
      return if letter.delivered?

      Letters::DeliverService.call(letter)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("DeliverLetterJob skipped — Letter ##{letter_id} not found")
    rescue *TRANSIENT_ERRORS
      raise
    rescue => e
      Letter.find_by(id: letter_id)&.update(status: "failed")
      Analytics::TrackEventService.call("delivery_failed", {
        letter_id: letter_id,
        error: e.message
      })
      raise
    end
  end
end
