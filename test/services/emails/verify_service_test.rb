require "test_helper"

class Emails::VerifyServiceTest < ActiveSupport::TestCase
  test "fails when token is blank" do
    result = Emails::VerifyService.call(nil)
    assert_not result.success?

    result = Emails::VerifyService.call("")
    assert_not result.success?
  end

  test "fails when token does not exist" do
    result = Emails::VerifyService.call("nonexistent-token")
    assert_not result.success?
  end

  test "fails when token is expired" do
    record = VerifiedEmail.create!(
      email: "expired@example.com",
      token: "exp-token",
      token_expires_at: 1.hour.ago
    )

    result = Emails::VerifyService.call(record.token)
    assert_not result.success?
    assert_not record.reload.verified?
  end

  test "verifies email and logs analytics event when token is valid" do
    record = VerifiedEmail.create!(
      email: "valid@example.com",
      token: "valid-token",
      token_expires_at: 24.hours.from_now
    )

    assert_difference -> { AnalyticsEvent.count } => 1 do
      result = Emails::VerifyService.call("valid-token")
      assert result.success?
      assert_equal "valid@example.com", result.verified_email.email
    end

    record.reload
    assert record.verified?
    assert_nil record.token
  end
end
