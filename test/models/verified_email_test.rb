require "test_helper"

class VerifiedEmailTest < ActiveSupport::TestCase
  test "valid verified email" do
    record = VerifiedEmail.new(email: "test@example.com")
    assert record.valid?
  end

  test "invalid without email" do
    record = VerifiedEmail.new(email: "")
    assert_not record.valid?
    assert record.errors[:email].any?
  end

  test "invalid with malformed email" do
    record = VerifiedEmail.new(email: "invalid-email")
    assert_not record.valid?
    assert record.errors[:email].any?
  end

  test "normalizes email to lowercase and strips whitespace" do
    record = VerifiedEmail.create!(email: "  USER@Example.COM  ")
    assert_equal "user@example.com", record.email
  end

  test "enforces case-insensitive email uniqueness" do
    VerifiedEmail.create!(email: "user@example.com")
    duplicate = VerifiedEmail.new(email: "USER@EXAMPLE.COM")
    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "verified? returns false when verified_at is nil" do
    record = VerifiedEmail.new(email: "user@example.com")
    assert_not record.verified?
  end

  test "verified? returns true when verified_at is present" do
    record = VerifiedEmail.new(email: "user@example.com", verified_at: Time.current)
    assert record.verified?
  end

  test "verify! sets verified_at and clears tokens" do
    record = VerifiedEmail.create!(
      email: "user@example.com",
      token: "sometoken",
      token_expires_at: 1.day.from_now
    )

    record.verify!
    assert record.verified?
    assert_not_nil record.verified_at
    assert_nil record.token
    assert_nil record.token_expires_at
  end

  test "generate_token! sets token and expiration" do
    record = VerifiedEmail.create!(email: "user@example.com")
    record.generate_token!

    assert_not_nil record.token
    assert_not_nil record.token_expires_at
    assert record.token_valid?
  end

  test "token_valid? returns false when token is expired" do
    record = VerifiedEmail.new(
      email: "user@example.com",
      token: "expired_token",
      token_expires_at: 1.hour.ago
    )
    assert_not record.token_valid?
  end

  test "VerifiedEmail.verified? checks presence of verified record" do
    assert_not VerifiedEmail.verified?("user@example.com")

    VerifiedEmail.create!(email: "user@example.com", verified_at: Time.current)
    assert VerifiedEmail.verified?("user@example.com")
    assert VerifiedEmail.verified?("USER@EXAMPLE.COM")
    assert_not VerifiedEmail.verified?(nil)
    assert_not VerifiedEmail.verified?("")
  end

  test "VerifiedEmail.verify! creates or updates record as verified" do
    record = VerifiedEmail.verify!("new_user@example.com")
    assert record.persisted?
    assert record.verified?

    # Call again for existing
    updated = VerifiedEmail.verify!("NEW_USER@EXAMPLE.COM")
    assert_equal record.id, updated.id
    assert updated.verified?
  end

  test "VerifiedEmail.generate_token_for creates token for unverified email" do
    record = VerifiedEmail.generate_token_for("token_user@example.com")
    assert record.persisted?
    assert_not record.verified?
    assert record.token_valid?
  end

  test "scopes filter verified and unverified records" do
    verified = VerifiedEmail.create!(email: "v@example.com", verified_at: Time.current)
    unverified = VerifiedEmail.create!(email: "u@example.com")

    assert_includes VerifiedEmail.verified, verified
    assert_not_includes VerifiedEmail.verified, unverified

    assert_includes VerifiedEmail.unverified, unverified
    assert_not_includes VerifiedEmail.unverified, verified
  end

  test "VerifiedEmail.verify! returns nil when email is blank" do
    assert_nil VerifiedEmail.verify!(nil)
    assert_nil VerifiedEmail.verify!("")
  end

  test "VerifiedEmail.generate_token_for returns nil when email is blank" do
    assert_nil VerifiedEmail.generate_token_for(nil)
    assert_nil VerifiedEmail.generate_token_for("")
  end

  test "VerifiedEmail.generate_token_for does not set token if email is already verified" do
    record = VerifiedEmail.verify!("already_verified@example.com")
    assert record.verified?

    res = VerifiedEmail.generate_token_for("already_verified@example.com")
    assert res.verified?
    assert_nil res.token
  end
end
