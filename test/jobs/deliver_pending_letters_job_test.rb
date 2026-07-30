require "test_helper"

class DeliverPendingLettersJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "performs delivery only for due pending letters" do
    # 1. Past due pending letter
    due_letter = Letter.new(
      title: "Due Letter",
      email: "due@example.com",
      content: "Hello from 2025!",
      deliver_at: 1.day.ago,
      status: "pending"
    )
    due_letter.save!(validate: false)

    # 2. Future pending letter (not due yet)
    future_letter = Letter.new(
      title: "Future Letter",
      email: "future@example.com",
      content: "Wait for me!",
      deliver_at: 1.month.from_now,
      status: "pending"
    )
    future_letter.save!(validate: false)

    # Verify that DeliverPendingLettersJob runs and delivers the due letter
    assert_emails 1 do
      DeliverPendingLettersJob.perform_now
    end

    due_letter.reload
    future_letter.reload

    # Due letter should be delivered
    assert_equal "delivered", due_letter.status
    assert_not_nil due_letter.delivered_at

    # Future letter should still be pending
    assert_equal "pending", future_letter.status
    assert_nil future_letter.delivered_at
  end
end
