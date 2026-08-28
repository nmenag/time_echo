class DeliverPendingLettersJob < ApplicationJob
  queue_as :default

  def perform
    letters = PendingLettersQuery.call.to_a
    Rails.logger.info("Queuing #{letters.size} pending letters for delivery")

    queued = 0
    letters.each do |letter|
      letter.update!(status: "queued", queued_at: Time.current)
      Letters::DeliverLetterJob.perform_later(letter.id)
      queued += 1
    end

    Rails.logger.info("Delivery dispatch complete queued=#{queued}")
  end
end
