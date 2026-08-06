require "test_helper"

class Webhooks::ResendsControllerTest < ActionDispatch::IntegrationTest
  test "should return ok on valid webhook JSON payload" do
    post resend_webhook_path, params: { type: "email.delivered", data: {} }.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :ok
  end

  test "should return bad request on invalid JSON payload" do
    post resend_webhook_path, params: "invalid json", headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :bad_request
  end
end
