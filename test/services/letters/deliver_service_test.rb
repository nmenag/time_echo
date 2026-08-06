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
    assert_equal "delivered", @letter.delivery_status
  end

  test "handles mailer error and updates delivery status to failed" do
    TimeCapsuleMailer.define_singleton_method(:future_letter) do |_|
      raise StandardError, "SMTP failure"
    end

    begin
      assert_raises StandardError do
        Letters::DeliverService.call(@letter)
      end
      @letter.reload
      assert_equal "failed", @letter.delivery_status
    ensure
      TimeCapsuleMailer.singleton_class.send(:remove_method, :future_letter)
    end
  end
end
