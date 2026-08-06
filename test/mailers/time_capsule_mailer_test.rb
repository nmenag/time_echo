require "test_helper"

class TimeCapsuleMailerTest < ActionMailer::TestCase
  test "magic_link email" do
    email = TimeCapsuleMailer.magic_link("user@example.com", "token123")
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ["user@example.com"], email.to
  end

  test "future_letter email" do
    letter = Letter.new(
      title: "Letter Title",
      email: "recipient@example.com",
      content: "Letter Content",
      deliver_at: 1.day.ago
    )
    letter.save!(validate: false)

    email = TimeCapsuleMailer.future_letter(letter)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ["recipient@example.com"], email.to
  end

  test "confirm_email_update email" do
    email = TimeCapsuleMailer.confirm_email_update("old@example.com", "new@example.com", "token456")
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ["new@example.com"], email.to
  end
end
