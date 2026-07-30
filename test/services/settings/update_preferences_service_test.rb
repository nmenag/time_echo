require "test_helper"

class Settings::UpdatePreferencesServiceTest < ActiveSupport::TestCase
  setup do
    @email = "traveler@timeecho.com"
    @prefs = UserPreference.find_or_create_by!(email: @email)
  end

  test "updates preferences successfully and logs event" do
    result = Settings::UpdatePreferencesService.call(
      @prefs,
      { theme: "luxury", appearance_mode: "dark" },
      @email
    )

    assert result.success?
    assert_equal :preferences_updated, result.action

    @prefs.reload
    assert_equal "luxury", @prefs.theme
    assert_equal "dark", @prefs.appearance_mode
  end

  test "requests an email update if email parameter differs" do
    assert_difference -> { SessionToken.count } => 1 do
      result = Settings::UpdatePreferencesService.call(
        @prefs,
        { email: "new_email@timeecho.com" },
        @email
      )

      assert result.success?
      assert_equal :email_update_requested, result.action
      assert_match "Hemos enviado un correo de confirmación", result.message
    end

    @prefs.reload
    assert_equal "new_email@timeecho.com", @prefs.unconfirmed_email
  end

  test "returns error when attempting to update to invalid email" do
    result = Settings::UpdatePreferencesService.call(
      @prefs,
      { email: "invalid-email" },
      @email
    )

    assert_not result.success?
    assert_match "correo electrónico válido", result.error
  end
end
