require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  class FailingJob < ApplicationJob
    def perform
      raise StandardError, "test error"
    end
  end

  test "logs error and re-raises exception on failure" do
    assert_raises(StandardError) do
      FailingJob.perform_now
    end
  end
end
