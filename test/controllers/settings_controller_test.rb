require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @email = "traveler@timeecho.com"
    @letter = Letter.create!(
      email: @email,
      title: "Letter to future",
      content: "Deep emotional retrospection.",
      deliver_at: Date.current + 1.year
    )
  end

  def sign_in(email)
    token_record = SessionToken.create!(email: email)
    get magic_login_path(token_record.token)
  end

  test "should redirect show when not logged in" do
    get settings_url
    assert_redirected_to login_url
  end

  test "should get settings page when logged in" do
    sign_in(@email)

    get settings_url
    assert_response :success
    assert_select "h1", text: "Ajustes de cuenta"
  end

  test "should update settings variables and persist them" do
    sign_in(@email)

    patch settings_url, params: {
      user_preference: {
        future_letter_reminders: false,
        theme: "luxury",
        appearance_mode: "dark",
        anonymous_analytics: false
      }
    }

    assert_redirected_to settings_url
    follow_redirect!
    assert_match "Ajustes guardados ✨", response.body

    # Verify database persistence
    prefs = UserPreference.find_by(email: @email)
    assert_not_nil prefs
    assert_not prefs.future_letter_reminders
    assert_equal "luxury", prefs.theme
    assert_equal "dark", prefs.appearance_mode
    assert_not prefs.anonymous_analytics
  end

  test "should update settings via turbo_stream" do
    sign_in(@email)

    patch settings_url, as: :turbo_stream, params: {
      user_preference: {
        theme: "pastel",
        surprise_memories: false
      }
    }

    assert_response :success
    assert_match "Ajustes actualizados correctamente", response.body

    # Verify persistence
    prefs = UserPreference.find_by(email: @email)
    assert_equal "pastel", prefs.theme
    assert_not prefs.surprise_memories
  end

  test "should destroy account and delete all associated letters, preferences and clear session" do
    sign_in(@email)

    # Confirm existences first
    assert_equal 1, Letter.where(email: @email).count
    assert_nothing_raised do
      UserPreference.find_or_create_by!(email: @email)
    end

    assert_difference -> { Letter.where(email: @email).count } => -1, -> { UserPreference.where(email: @email).count } => -1 do
      delete settings_url
    end

    assert_redirected_to root_url
    assert_nil session[:current_user_email]
  end
end
