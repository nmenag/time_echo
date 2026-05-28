class DeliverPendingLettersJob < ApplicationJob
  queue_as :default

  def perform
    # Find all letters that are due and lock them for processing
    Letter.transaction do
      pending_letters = PendingLettersQuery.call.to_a
      pending_letters.each do |letter|
        begin
          Letters::DeliverService.call(letter)
        rescue => e
          Rails.logger.error("Failed to deliver Letter #{letter.id}: #{e.message}")
        end
      end
    end
  end
end
