require "test_helper"

class Letters::DeliverServiceTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.new(
      title: "Deliver Service Test",
      email: "deliver@example.com",
      content: "Testing delivery",
      deliver_at: 1.day.ago,
      status: "pending"
    )
    @letter.save!(validate: false)
  end

  test "returns early if already delivered" do
    @letter.update!(status: "delivered")
    assert_nothing_raised do
      Letters::DeliverService.call(@letter)
    end
  end

  test "delivers letter successfully" do
    Letters::DeliverService.call(@letter)
    @letter.reload
    assert_equal "delivered", @letter.status
  end

  test "delivers letter using stored language" do
    @letter.update!(language: "es")
    delivered_locale = nil

    original_future_letter = TimeCapsuleMailer.method(:future_letter)
    TimeCapsuleMailer.define_singleton_method(:future_letter) do |letter|
      delivered_locale = I18n.locale.to_s
      original_future_letter.call(letter)
    end

    I18n.with_locale(:en) do
      Letters::DeliverService.call(@letter)
    end

    assert_equal "es", delivered_locale
  ensure
    TimeCapsuleMailer.define_singleton_method(:future_letter, original_future_letter.to_proc)
  end

  test "handles mailer error and updates status to failed" do
    original_future_letter = TimeCapsuleMailer.method(:future_letter)
    TimeCapsuleMailer.define_singleton_method(:future_letter) do |*args|
      raise StandardError, "SMTP failure"
    end

    assert_raises StandardError do
      Letters::DeliverService.call(@letter)
    end

    @letter.reload
    assert_equal "failed", @letter.status
  ensure
    TimeCapsuleMailer.define_singleton_method(:future_letter, original_future_letter.to_proc)
  end
end
