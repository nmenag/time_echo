require "test_helper"

class LetterTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.new(
      title: "Model Test",
      email: "model@example.com",
      content: "Testing model",
      deliver_at: 1.day.from_now,
      status: "pending"
    )
  end

  test "predicates draft?, pending?, delivered?" do
    @letter.status = "draft"
    assert @letter.draft?
    assert_not @letter.pending?
    assert_not @letter.delivered?

    @letter.status = "pending"
    assert @letter.pending?

    @letter.status = "delivered"
    assert @letter.delivered?
  end

  test "countdown_seconds" do
    @letter.status = "delivered"
    assert_equal 0, @letter.countdown_seconds

    @letter.status = "pending"
    @letter.deliver_at = 1.hour.from_now
    assert @letter.countdown_seconds > 0

    @letter.deliver_at = 1.hour.ago
    assert_equal 0, @letter.countdown_seconds
  end

  test "scopes scheduled and for_email" do
    @letter.save!(validate: false)
    assert_includes Letter.scheduled, @letter
    assert_includes Letter.for_email("model@example.com"), @letter
  end

  test "deliver_at must be in the future" do
    @letter.deliver_at = 1.hour.ago
    assert_not @letter.valid?
    assert_includes @letter.errors[:deliver_at], "must be in the future"
  end
end
