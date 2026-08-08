require "test_helper"

class TimeCapsuleMailerTest < ActionMailer::TestCase
  test "magic_link" do
    mail = TimeCapsuleMailer.magic_link("user@example.com", "token123")
    assert_equal ["user@example.com"], mail.to
    assert_equal I18n.t("mailers.magic_link.subject"), mail.subject
  end

  test "future_letter" do
    letter = Letter.new(
      title: "Test",
      email: "user@example.com",
      content: "Hello",
      deliver_at: 1.day.ago,
      status: "delivered"
    )
    letter.save!(validate: false)
    mail = TimeCapsuleMailer.future_letter(letter)
    assert_equal ["user@example.com"], mail.to
  end

  test "confirm_email_update" do
    mail = TimeCapsuleMailer.confirm_email_update("old@example.com", "new@example.com", "token123")
    assert_equal ["new@example.com"], mail.to
    assert_equal I18n.t("mailers.confirm_email_update.subject"), mail.subject
  end
end
