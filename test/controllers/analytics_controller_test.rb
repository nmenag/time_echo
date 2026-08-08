require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get analytics page when logged in" do
    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    get analytics_path
    assert_response :success
  end

  test "should redirect analytics when not logged in" do
    get analytics_path
    assert_redirected_to login_path
  end
end
