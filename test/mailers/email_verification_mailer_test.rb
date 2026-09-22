require "test_helper"

class EmailVerificationMailerTest < ActionMailer::TestCase
  test "confirm_email" do
    mail = EmailVerificationMailer.confirm_email("old@example.com", "new@example.com", "token123")
    assert_equal [ "new@example.com" ], mail.to
    assert_equal [ "no-reply@timeecho.me" ], mail.from
    assert_equal "TimeEcho <no-reply@timeecho.me>", mail[:from].decoded
    assert_equal I18n.t("mailers.confirm_email.subject"), mail.subject
  end

  test "confirm_email renders html and text parts with transition" do
    mail = EmailVerificationMailer.confirm_email("old@example.com", "new@example.com", "token123")
    html_body = mail.html_part.body.decoded
    text_body = mail.text_part.body.decoded

    assert_includes html_body, "old@example.com"
    assert_includes html_body, "new@example.com"
    assert_includes html_body, "btn-carmine"
    assert_includes text_body, "new@example.com"
  end

  test "verify_email renders subject, recipients, and verification link" do
    mail = EmailVerificationMailer.verify_email("verify@example.com", "token789")
    assert_equal [ "verify@example.com" ], mail.to
    assert_equal [ "no-reply@timeecho.me" ], mail.from
    assert_equal I18n.t("mailers.verify_email.subject"), mail.subject

    html_body = mail.html_part.body.decoded
    text_body = mail.text_part.body.decoded

    assert_includes html_body, "token789"
    assert_includes html_body, "btn-carmine"
    assert_includes text_body, "token789"
  end
end
