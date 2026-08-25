class PendingLettersQuery
  def self.call
    new.call
  end

  def call
    Letter.where(status: [ "pending", "failed" ])
          .where("deliver_at <= ?", Time.current)
          .lock("FOR UPDATE SKIP LOCKED")
  end
end
