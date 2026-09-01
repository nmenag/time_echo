module Letters
  class DispatchPendingService
    def self.call
      new.call
    end

    def call
      letters = PendingLettersQuery.call.to_a
      Rails.logger.info("Queuing #{letters.size} pending letters for delivery")

      queued = 0
      letters.each do |letter|
        letter.update!(status: "queued", queued_at: Time.current)
        Letters::DeliverLetterJob.perform_later(letter.id)
        queued += 1
      end

      Rails.logger.info("Delivery dispatch complete queued=#{queued}")
      queued
    end
  end
end
