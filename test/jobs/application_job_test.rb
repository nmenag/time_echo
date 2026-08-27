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

  setup do
    @original_logger = Rails.logger
    @stubbed_logger = Logger.new(File::NULL)
    Rails.logger = @stubbed_logger
  end

  teardown do
    Rails.logger = @original_logger
  end

  test "logs start, finish with duration, and yields on success" do
    logs = []
    @stubbed_logger.define_singleton_method(:info) { |msg| logs << msg }
    @stubbed_logger.define_singleton_method(:tagged) { |*_args, &block| block&.call }

    result = SuccessfulJob.perform_now

    assert_equal "success", result
    assert logs.any? { |msg| msg.include?("SuccessfulJob started") }
    assert logs.any? { |msg| msg.include?("SuccessfulJob finished duration_ms=") }
  end

  test "includes cron_key in tags when present" do
    tags = []
    @stubbed_logger.define_singleton_method(:tagged) do |*args, &block|
      tags.concat(args)
      block&.call
    end
    @stubbed_logger.define_singleton_method(:info) { |*_args| }
    @stubbed_logger.define_singleton_method(:error) { |*_args| }

    GoodJob::CurrentThread.cron_key = "daily_cleanup"
    SuccessfulJob.perform_now

    assert_includes tags, "job:ApplicationJobTest::SuccessfulJob"
    assert_includes tags, "cron:daily_cleanup"
  ensure
    GoodJob::CurrentThread.cron_key = nil
  end

  test "omits cron_key tag when not present" do
    tags = []
    @stubbed_logger.define_singleton_method(:tagged) do |*args, &block|
      tags.concat(args)
      block&.call
    end
    @stubbed_logger.define_singleton_method(:info) { |*_args| }
    @stubbed_logger.define_singleton_method(:error) { |*_args| }

    SuccessfulJob.perform_now

    assert_includes tags, "job:ApplicationJobTest::SuccessfulJob"
    assert tags.none? { |tag| tag.start_with?("cron:") }
  end

  test "logs error and re-raises exception on failure" do
    errors = []
    @stubbed_logger.define_singleton_method(:error) { |msg| errors << msg }
    @stubbed_logger.define_singleton_method(:tagged) { |*_args, &block| block&.call }

    assert_raises(StandardError) do
      FailingJob.perform_now
    end

    assert_equal 1, errors.size
    assert errors.first.include?("FailingJob failed error=StandardError: test error")
  end
end
