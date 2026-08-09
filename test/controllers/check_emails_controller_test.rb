require "test_helper"

class CheckEmailsControllerTest < ActionDispatch::IntegrationTest
  test "should show check email page" do
    get check_email_path(email: "test@example.com")
    assert_response :success
    assert_select "h1", text: I18n.t("sessions.check_email_title")
    assert_select "strong", text: "test@example.com"
  end
end
