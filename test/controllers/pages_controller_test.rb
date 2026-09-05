require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get landing page when not logged in" do
    get root_path
    assert_response :success
  end

  test "should redirect landing to dashboard when logged in" do
    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    get root_path
    assert_redirected_to dashboard_path
  end

  test "does not render google analytics when GOOGLE_ANALYTICS_ID is not set" do
    original = ENV["GOOGLE_ANALYTICS_ID"]
    begin
      ENV["GOOGLE_ANALYTICS_ID"] = nil
      get root_path
      assert_response :success
      assert_no_match(/googletagmanager\.com\/gtag\/js/, response.body)
    ensure
      ENV["GOOGLE_ANALYTICS_ID"] = original
    end
  end

  test "renders google analytics when GOOGLE_ANALYTICS_ID is present" do
    original = ENV["GOOGLE_ANALYTICS_ID"]
    begin
      ENV["GOOGLE_ANALYTICS_ID"] = "G-TEST12345"
      get root_path
      assert_response :success
      assert_match(/googletagmanager\.com\/gtag\/js\?id=G-TEST12345/, response.body)
      assert_match(/G-TEST12345/, response.body)
      assert_match(/turbo:load/, response.body)
    ensure
      ENV["GOOGLE_ANALYTICS_ID"] = original
    end
  end
end
