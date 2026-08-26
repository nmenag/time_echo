require "test_helper"

class Analytics::FetchMetricsServiceTest < ActiveSupport::TestCase
  setup do
    @user = "user@example.com"
  end

  test "returns empty metrics when no letters" do
    metrics = Analytics::FetchMetricsService.call(@user)
    assert_equal 0, metrics.total_letters
    assert_equal 0, metrics.delivered_letters
    assert_equal 0, metrics.scheduled_letters
  end

  test "returns correct metrics with letters" do
    letter = Letter.new(title: "Test", email: @user, content: "Hello", deliver_at: 1.day.ago, status: "delivered")
    letter.save!(validate: false)

    metrics = Analytics::FetchMetricsService.call(@user)
    assert_equal 1, metrics.total_letters
    assert_equal 1, metrics.delivered_letters
    assert_equal 0, metrics.scheduled_letters
  end
end
