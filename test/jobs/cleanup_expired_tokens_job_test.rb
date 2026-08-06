require "test_helper"

class CleanupExpiredTokensJobTest < ActiveJob::TestCase
  test "deletes expired and used session tokens" do
    SessionToken.create!(email: "expired@example.com", token: "exp123", expires_at: 1.hour.ago)
    SessionToken.create!(email: "used@example.com", token: "used123", expires_at: 1.hour.from_now, used_at: Time.current)
    valid_token = SessionToken.create!(email: "valid@example.com", token: "valid123", expires_at: 1.hour.from_now)

    assert_difference -> { SessionToken.count } => -2 do
      CleanupExpiredTokensJob.perform_now
    end

    assert SessionToken.exists?(valid_token.id)
  end
end
