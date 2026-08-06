require "test_helper"

class LetterPredictionsControllerTest < ActionDispatch::IntegrationTest
  test "redirects to root when letter not found" do
    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    post update_predictions_letter_path(letter_id: "nonexistent")
    assert_redirected_to root_path
  end

  test "redirects to root when unauthorized" do
    letter = Letter.new(title: "Letter", email: "other@example.com", content: "Hi", deliver_at: 1.day.ago, status: "delivered")
    letter.save!(validate: false)

    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    post update_predictions_letter_path(letter)
    assert_redirected_to root_path
    assert_equal t("flash.unauthorized_modify"), flash[:alert]
  end

  test "redirects to root on validation error" do
    letter = Letter.new(title: "Letter", email: "user@example.com", content: "Hi", deliver_at: 1.day.ago, status: "delivered")
    letter.save!(validate: false)

    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    post update_predictions_letter_path(letter), params: { reveal_happiness: 99 }
    assert_redirected_to root_path
  end
end
