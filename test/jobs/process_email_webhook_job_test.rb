require "test_helper"

class ProcessEmailWebhookJobTest < ActiveJob::TestCase
  setup do
    @letter = Letter.new(
      title: "Webhook Test Letter",
      email: "webhook@example.com",
      content: "Testing webhook processing",
      deliver_at: 1.day.ago,
      status: "delivered"
    )
    @letter.save!(validate: false)
  end

  test "processes email.delivered event" do
    payload = {
      "type" => "email.delivered",
      "data" => {
        "email_id" => "resend_123",
        "tags" => { "letter_id" => @letter.id.to_s }
      }
    }

    ProcessEmailWebhookJob.perform_now(payload)
    @letter.reload
    assert_equal "delivered", @letter.delivery_status
  end

  test "processes email.opened event" do
    payload = {
      "type" => "email.opened",
      "data" => {
        "email_id" => "resend_123",
        "headers" => { "X-Letter-ID" => @letter.id.to_s }
      }
    }

    assert_difference -> { @letter.reload.open_count } => 1 do
      ProcessEmailWebhookJob.perform_now(payload)
    end
    assert_not_nil @letter.opened_at
  end

  test "processes email.clicked event" do
    payload = {
      "type" => "email.clicked",
      "data" => {
        "email_id" => "resend_123",
        "tags" => { "letter_id" => @letter.id.to_s }
      }
    }

    ProcessEmailWebhookJob.perform_now(payload)
    @letter.reload
    assert_not_nil @letter.clicked_at
  end

  test "processes email.bounced event" do
    payload = {
      "type" => "email.bounced",
      "data" => {
        "email_id" => "resend_123",
        "tags" => { "letter_id" => @letter.id.to_s }
      }
    }

    ProcessEmailWebhookJob.perform_now(payload)
    @letter.reload
    assert_equal "bounced", @letter.delivery_status
  end

  test "processes unknown event" do
    payload = {
      "type" => "email.complained",
      "data" => { "email_id" => "resend_123" }
    }

    assert_nothing_raised do
      ProcessEmailWebhookJob.perform_now(payload)
    end
  end
end
