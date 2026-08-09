require "test_helper"

class Settings::UpdatePreferencesServiceTest < ActiveSupport::TestCase
  setup do
    @preference = UserPreference.create!(email: "user@example.com")
  end

  test "updates preferences when email unchanged" do
    result = Settings::UpdatePreferencesService.call(@preference, { theme: "cupcake" }, "user@example.com")
    assert result.success?
    assert_equal :preferences_updated, result.action
    @preference.reload
    assert_equal "cupcake", @preference.theme
  end

  test "requests email update when email changed" do
    result = Settings::UpdatePreferencesService.call(@preference, { email: "new@example.com" }, "user@example.com")
    assert result.success?
    assert_equal :email_update_requested, result.action
  end

  test "returns failure when update fails" do
    result = Settings::UpdatePreferencesService.call(@preference, { appearance_mode: "invalid" }, "user@example.com")
    assert_not result.success?
  end

  test "returns failure when email update service fails" do
    struct_fail = Struct.new(:success?, :error).new(false, "Update failed")
    original_call = Settings::RequestEmailUpdateService.method(:call)
    Settings::RequestEmailUpdateService.define_singleton_method(:call, ->(*) { struct_fail })

    result = Settings::UpdatePreferencesService.call(@preference, { email: "new@example.com" }, "user@example.com")
    assert_not result.success?
    assert_equal "Update failed", result.error
  ensure
    Settings::RequestEmailUpdateService.define_singleton_method(:call, original_call.to_proc)
  end
end
