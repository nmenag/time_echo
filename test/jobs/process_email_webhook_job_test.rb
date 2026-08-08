require "test_helper"

class ProcessEmailWebhookJobTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Content",
      deliver_at: 1.day.ago,
      status: "delivered"
    )
    @letter.save!(validate: false)
  end

  test "processes email.delivered event" do
    ProcessEmailWebhookJob.new.perform("type" => "email.delivered", "data" => { "email_id" => "123", "tags" => { "letter_id" => @letter.id.to_s } })
    @letter.reload
    assert_equal "delivered", @letter.delivery_status
  end

  test "processes email.opened event" do
    ProcessEmailWebhookJob.new.perform("type" => "email.opened", "data" => { "email_id" => "123", "tags" => { "letter_id" => @letter.id.to_s } })
    @letter.reload
    assert_equal 1, @letter.open_count
    assert_not_nil @letter.opened_at
  end

  test "processes email.clicked event" do
    ProcessEmailWebhookJob.new.perform("type" => "email.clicked", "data" => { "email_id" => "123", "tags" => { "letter_id" => @letter.id.to_s } })
    @letter.reload
    assert_not_nil @letter.clicked_at
  end

  test "processes email.bounced event" do
    ProcessEmailWebhookJob.new.perform("type" => "email.bounced", "data" => { "email_id" => "123", "tags" => { "letter_id" => @letter.id.to_s } })
    @letter.reload
    assert_equal "bounced", @letter.delivery_status
  end

  test "processes unknown event type and tracks it" do
    assert_difference -> { AnalyticsEvent.count } => 1 do
      ProcessEmailWebhookJob.new.perform("type" => "email.unknown", "data" => { "email_id" => "123" })
    end
  end
end
