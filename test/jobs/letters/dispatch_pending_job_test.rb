require "test_helper"

class Letters::DispatchPendingJobTest < ActiveJob::TestCase
  test "performs dispatch pending service and returns queued count" do
    result = Letters::DispatchPendingJob.perform_now
    assert_kind_of Integer, result
  end

  test "is enqueued in default queue" do
    assert_enqueued_with(job: Letters::DispatchPendingJob, queue: "default") do
      Letters::DispatchPendingJob.perform_later
    end
  end
end
