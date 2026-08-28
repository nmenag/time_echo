require "test_helper"

class DeliverPendingLettersJobTest < ActiveJob::TestCase
  def build_letter(overrides = {})
    letter = Letter.new({
      title: "Test Letter",
      email: "test@example.com",
      content: "Hello from the past!",
      deliver_at: 1.day.ago,
      status: "pending"
    }.merge(overrides))
    letter.save!(validate: false)
    letter
  end

  test "marks due pending letters as queued and enqueues DeliverLetterJob" do
    due_letter = build_letter

    assert_enqueued_with(job: Letters::DeliverLetterJob, args: [ due_letter.id ]) do
      DeliverPendingLettersJob.perform_now
    end

    due_letter.reload
    assert_equal "queued", due_letter.status
    assert_not_nil due_letter.queued_at
  end

  test "does not enqueue jobs for future letters" do
    future_letter = build_letter(deliver_at: 1.month.from_now, status: "pending")

    assert_no_enqueued_jobs(only: Letters::DeliverLetterJob) do
      DeliverPendingLettersJob.perform_now
    end

    future_letter.reload
    assert_equal "pending", future_letter.status
  end

  test "does not re-process already queued letters" do
    queued_letter = build_letter(status: "queued")

    assert_no_enqueued_jobs(only: Letters::DeliverLetterJob) do
      DeliverPendingLettersJob.perform_now
    end

    queued_letter.reload
    assert_equal "queued", queued_letter.status
  end

  test "does not re-process already delivered letters" do
    delivered_letter = build_letter(status: "delivered")

    assert_no_enqueued_jobs(only: Letters::DeliverLetterJob) do
      DeliverPendingLettersJob.perform_now
    end

    delivered_letter.reload
    assert_equal "delivered", delivered_letter.status
  end

  test "does not re-process already failed letters" do
    failed_letter = build_letter(status: "failed")

    assert_no_enqueued_jobs(only: Letters::DeliverLetterJob) do
      DeliverPendingLettersJob.perform_now
    end

    failed_letter.reload
    assert_equal "failed", failed_letter.status
  end

  test "enqueues one job per due pending letter" do
    3.times { |i| build_letter(email: "user#{i}@example.com") }

    assert_enqueued_jobs 3, only: Letters::DeliverLetterJob do
      DeliverPendingLettersJob.perform_now
    end
  end
end
