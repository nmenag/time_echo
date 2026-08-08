require "test_helper"

class LetterSuccessesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect when no flash data" do
    get success_letters_path
    assert_redirected_to root_path
  end

  test "should show success page with flash data" do
    post letters_path, params: { letter_form: { title: "Test", email: "test@example.com", content: "Hello", deliver_at: 1.year.from_now.to_s } }
    assert_redirected_to success_letters_path
    follow_redirect!
    assert_response :success
  end
end
