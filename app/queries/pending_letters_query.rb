class PendingLettersQuery
  def self.call
    new.call
  end

  def call
    Letter.pending
          .joins("INNER JOIN verified_emails ON LOWER(letters.email) = LOWER(verified_emails.email)")
          .where.not(verified_emails: { verified_at: nil })
          .lock("FOR UPDATE SKIP LOCKED")
  end
end
