module Letters
  class DeliverLetterJob < ApplicationJob
    queue_as :mailers

    retry_on Net::OpenTimeout, Net::ReadTimeout, Timeout::Error,
             wait: :polynomially_longer, attempts: 5

    discard_on ActiveJob::DeserializationError do |job, error|
      Rails.logger.error("#{job.class} discarded — letter record missing: #{error.message}")
    end

    def perform(letter_id)
      letter = Letter.find(letter_id)
      return if letter.delivered?

      Letters::DeliverService.call(letter)
    rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error
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
