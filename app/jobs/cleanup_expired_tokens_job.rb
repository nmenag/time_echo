class CleanupExpiredTokensJob < ApplicationJob
  queue_as :default

  def perform
    deleted_count = SessionToken.where("expires_at <= ?", Time.current)
                                .or(SessionToken.where.not(used_at: nil))
                                .delete_all

    Rails.logger.info("Cleaned up #{deleted_count} expired tokens")

    Analytics::TrackEventService.call("cleanup_expired_tokens", {
      deleted_count: deleted_count,
      occurred_at: Time.current
    })
  end
end
