require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect index when not authenticated" do
    get analytics_path
    assert_redirected_to login_path
  end

  test "should get index when authenticated" do
    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    get analytics_path
    assert_response :success
  end
end
