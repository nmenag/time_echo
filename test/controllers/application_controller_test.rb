require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "set_locale sets Spanish when Accept-Language is es" do
    get root_path, headers: { "Accept-Language" => "es" }
    assert_equal :es, I18n.locale
  end

  test "set_locale sets English when Accept-Language is en" do
    get root_path, headers: { "Accept-Language" => "en" }
    assert_equal :en, I18n.locale
  end

  test "set_locale does not override locale for unsupported Accept-Language" do
    I18n.locale = :es
    get root_path, headers: { "Accept-Language" => "fr" }
    assert_equal :es, I18n.locale
  end

  test "set_locale does not override when no Accept-Language header is sent" do
    I18n.locale = :es
    get root_path
    assert_equal :es, I18n.locale
  end

  test "current_user_theme defaults to timeecho when not signed in" do
    get root_path
    assert_response :success
    assert_select "html[data-theme='timeecho']"
  end

  test "current_user_theme defaults to timeecho when signed in without preference" do
    token_record = SessionToken.create!(email: "user@example.com")
    get magic_login_path(token_record.token)

    get dashboard_path
    assert_response :success
    assert_select "html[data-theme='timeecho']"
  end

  test "current_user_theme uses user preference theme when set" do
    email = "themer@timeecho.com"
    UserPreference.create!(email: email, theme: "cupcake")
    token_record = SessionToken.create!(email: email)
    get magic_login_path(token_record.token)

    get dashboard_path
    assert_response :success
    assert_select "html[data-theme='cupcake']"
  end
end
