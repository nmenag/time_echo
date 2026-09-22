require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  test "successfully verifies email with valid token" do
    record = VerifiedEmail.create!(
      email: "user@example.com",
      token: "secret-token",
      token_expires_at: 24.hours.from_now
    )

    get verify_email_path("secret-token")

    assert_redirected_to dashboard_path
    assert_equal "user@example.com", session[:current_user_email]
    assert_equal I18n.t("flash.email_verified"), flash[:notice]
    assert record.reload.verified?
  end

  test "redirects to login with alert on invalid token" do
    get verify_email_path("invalid-token")

    assert_redirected_to login_path
    assert_nil session[:current_user_email]
    assert_equal I18n.t("flash.invalid_or_expired_verification_token"), flash[:alert]
  end

  test "redirects to login with alert on expired token" do
    record = VerifiedEmail.create!(
      email: "user@example.com",
      token: "expired-token",
      token_expires_at: 1.hour.ago
    )

    get verify_email_path("expired-token")

    assert_redirected_to login_path
    assert_nil session[:current_user_email]
    assert_not record.reload.verified?
  end
end
