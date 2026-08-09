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
  end

  test "redirects to root when unauthorized to update predictions" do
    letter = Letter.new(title: "Letter", email: "user@example.com", content: "Hi", deliver_at: 1.day.ago, status: "delivered")
    letter.save!(validate: false)

    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    struct_unauth = Struct.new(:success?, :error, :message).new(false, :unauthorized, nil)
    original_call = Letters::UpdatePredictionsService.method(:call)
    Letters::UpdatePredictionsService.define_singleton_method(:call, ->(*) { struct_unauth })

    post update_predictions_letter_path(letter)
    assert_redirected_to root_path
  ensure
    Letters::UpdatePredictionsService.define_singleton_method(:call, original_call.to_proc)
  end

  test "redirects to root on general error" do
    letter = Letter.new(title: "Letter", email: "user@example.com", content: "Hi", deliver_at: 1.day.ago, status: "delivered")
    letter.save!(validate: false)

    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    struct_fail = Struct.new(:success?, :error, :message).new(false, :other, "Custom error")
    original_call = Letters::UpdatePredictionsService.method(:call)
    Letters::UpdatePredictionsService.define_singleton_method(:call, ->(*) { struct_fail })

    post update_predictions_letter_path(letter)
    assert_redirected_to root_path
  ensure
    Letters::UpdatePredictionsService.define_singleton_method(:call, original_call.to_proc)
  end
end
