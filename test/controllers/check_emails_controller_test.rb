require "test_helper"

class CheckEmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get check_email_path(email: "test@example.com")
    assert_response :success
  end
end
