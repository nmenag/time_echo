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

  test "logs error when letter delivery fails" do
    due_letter = Letter.new(
      title: "Failing Letter",
      email: "fail@example.com",
      content: "Fail content",
      deliver_at: 1.day.ago,
      status: "pending"
    )
    due_letter.save!(validate: false)

    original_call = Letters::DeliverService.method(:call)
    Letters::DeliverService.define_singleton_method(:call) do |*args|
      raise StandardError, "Delivery error"
    end

    assert_nothing_raised do
      DeliverPendingLettersJob.perform_now
    end
  ensure
    Letters::DeliverService.define_singleton_method(:call, original_call.to_proc)
  end
end
