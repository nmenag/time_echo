require "test_helper"

class CleanupExpiredTokensJobTest < ActiveSupport::TestCase
  test "deletes expired tokens" do
    expired = SessionToken.create!(email: "old@example.com", expires_at: 1.day.ago)
    valid = SessionToken.create!(email: "new@example.com", expires_at: 1.day.from_now)

    assert_difference -> { SessionToken.count } => -1 do
      CleanupExpiredTokensJob.new.perform
    end

    assert SessionToken.exists?(valid.id)
    assert_not SessionToken.exists?(expired.id)
  end

  test "deletes used tokens" do
    used = SessionToken.create!(email: "used@example.com", used_at: Time.current)
    valid = SessionToken.create!(email: "new@example.com")

    assert_difference -> { SessionToken.count } => -1 do
      CleanupExpiredTokensJob.new.perform
    end

    assert_not SessionToken.exists?(used.id)
  end
end
