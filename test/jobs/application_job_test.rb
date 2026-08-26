require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  class SuccessfulJob < ApplicationJob
    def perform
      "success"
    end
  end

  class FailingJob < ApplicationJob
    def perform
      raise StandardError, "test error"
    end
  end

  test "logs start, finish with duration, and yields on success" do
    logs = []
    Rails.logger.define_singleton_method(:info) { |msg| logs << msg }
    Rails.logger.define_singleton_method(:tagged) { |*tags, &block| block&.call }

    result = SuccessfulJob.perform_now

    assert_equal "success", result
    assert logs.any? { |msg| msg.include?("SuccessfulJob started") }
    assert logs.any? { |msg| msg.include?("SuccessfulJob finished duration_ms=") }
  end

  test "includes cron_key in tags when present" do
    tags = []
    Rails.logger.define_singleton_method(:tagged) do |*args, &block|
      tags.concat(args)
      block&.call
    end
    Rails.logger.define_singleton_method(:info) { }
    Rails.logger.define_singleton_method(:error) { }

    GoodJob::CurrentThread.cron_key = "daily_cleanup"
    SuccessfulJob.perform_now

    assert_includes tags, "job:SuccessfulJob"
    assert_includes tags, "cron:daily_cleanup"
  ensure
    GoodJob::CurrentThread.cron_key = nil
  end

  test "omits cron_key tag when not present" do
    tags = []
    Rails.logger.define_singleton_method(:tagged) do |*args, &block|
      tags.concat(args)
      block&.call
    end
    Rails.logger.define_singleton_method(:info) { }
    Rails.logger.define_singleton_method(:error) { }

    SuccessfulJob.perform_now

    assert_includes tags, "job:SuccessfulJob"
    assert tags.none? { |tag| tag.start_with?("cron:") }
  end

  test "logs error and re-raises exception on failure" do
    errors = []
    Rails.logger.define_singleton_method(:error) { |msg| errors << msg }
    Rails.logger.define_singleton_method(:tagged) { |*tags, &block| block&.call }

    assert_raises(StandardError) do
      FailingJob.perform_now
    end

    assert_equal 1, errors.size
    assert errors.first.include?("FailingJob failed error=StandardError: test error")
  end
end
