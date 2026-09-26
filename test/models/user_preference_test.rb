require "test_helper"

class UserPreferenceTest < ActiveSupport::TestCase
  test "valid with unique email" do
    pref = UserPreference.new(email: "valid@example.com")
    assert pref.valid?
  end

  test "invalid without email" do
    pref = UserPreference.new(email: nil)
    assert_not pref.valid?
    assert_includes pref.errors[:email], I18n.t("errors.messages.blank")
  end

  test "invalid with duplicate email" do
    UserPreference.create!(email: "duplicate@example.com")
    duplicate = UserPreference.new(email: "duplicate@example.com")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], I18n.t("errors.messages.taken")
  end

  test "normalizes email by stripping and downcasing" do
    pref = UserPreference.create!(email: "  SPACES@Example.COM ")
    assert_equal "spaces@example.com", pref.email
  end
end
