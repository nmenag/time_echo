require "test_helper"

class LetterSuccessesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect show to root when flash parameters missing" do
    get success_letters_path
    assert_redirected_to root_path
  end
end
