require "test_helper"

class Webhooks::ResendsControllerTest < ActionDispatch::IntegrationTest
  test "should accept valid webhook payload" do
    post resend_webhook_path, params: { type: "email.delivered", data: { email_id: "123", tags: { letter_id: "1" } } }.to_json, headers: { "Content-Type" => "application/json" }
    assert_response :success
  end

  test "should reject invalid JSON payload" do
    post resend_webhook_path, params: "not json", headers: { "Content-Type" => "application/json" }
    assert_response :bad_request
  end
end
