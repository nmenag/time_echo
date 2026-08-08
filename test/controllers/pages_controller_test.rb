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
end
