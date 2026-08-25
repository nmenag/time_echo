class DeliverPendingLettersJob < ApplicationJob
  queue_as :default

  def perform
    pending_letters = PendingLettersQuery.call.to_a
    Rails.logger.info("Delivering #{pending_letters.size} pending letters")

    delivered = 0
    failed = 0
    Letter.transaction do
      pending_letters.each do |letter|
        Letters::DeliverService.call(letter)
        delivered += 1
      rescue => e
        failed += 1
        Rails.logger.error("Failed to deliver Letter #{letter.id}: #{e.message}")
      end
    end

    Rails.logger.info("Delivery complete delivered=#{delivered} failed=#{failed}")
  end
end
