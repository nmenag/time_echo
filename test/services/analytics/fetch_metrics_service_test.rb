require "test_helper"

class Analytics::FetchMetricsServiceTest < ActiveSupport::TestCase
  test "should return metrics for user email without sql grouping errors" do
    email = "user@example.com"

    # Create test letters
    letter1 = Letter.create!(
      title: "Letter 1",
      email: email,
      content: "Hello future self!",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    letter1.create_emotional_snapshot!(happiness_level: 7, anxiety_level: 3, motivation_level: 8)

    letter2 = Letter.new(
      title: "Letter 2",
      email: email,
      content: "Hello again!",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered",
      reveal_happiness: 8,
      reveal_anxiety: 2,
      reveal_motivation: 9
    )
    letter2.save!(validate: false)
    letter2.create_emotional_snapshot!(happiness_level: 5, anxiety_level: 5, motivation_level: 5)

    metrics = Analytics::FetchMetricsService.call(email)

    assert_equal 2, metrics.total_letters
    assert_equal 1, metrics.delivered_letters
    assert_equal 1, metrics.scheduled_letters
    assert_equal 8.0, metrics.avg_reveal_happiness
    assert_equal 2.0, metrics.avg_reveal_anxiety
    assert_equal 9.0, metrics.avg_reveal_motivation
    assert_equal 6.0, metrics.avg_initial_happiness # (7 + 5) / 2
  end
end
