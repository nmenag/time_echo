require "test_helper"

class AuthMailerTest < ActionMailer::TestCase
  test "magic_link" do
    mail = AuthMailer.magic_link("user@example.com", "token123")
    assert_equal [ "user@example.com" ], mail.to
    assert_equal [ "no-reply@timeecho.me" ], mail.from
    assert_equal "TimeEcho <no-reply@timeecho.me>", mail[:from].decoded
    assert_equal I18n.t("mailers.magic_link.subject"), mail.subject
  end

  test "confirm_email_update" do
    mail = AuthMailer.confirm_email_update("old@example.com", "new@example.com", "token123")
    assert_equal [ "new@example.com" ], mail.to
    assert_equal [ "no-reply@timeecho.me" ], mail.from
    assert_equal "TimeEcho <no-reply@timeecho.me>", mail[:from].decoded
    assert_equal I18n.t("mailers.confirm_email_update.subject"), mail.subject
  end

  test "magic_link renders html and text parts with carmine button" do
    mail = AuthMailer.magic_link("user@example.com", "token123")
    html_body = mail.html_part.body.decoded
    text_body = mail.text_part.body.decoded

    assert_includes html_body, "TimeEcho"
    assert_includes html_body, "btn-carmine"
    assert_includes html_body, "token123"
    assert_includes text_body, "token123"
  end

  test "confirm_email_update renders html and text parts with transition" do
    mail = AuthMailer.confirm_email_update("old@example.com", "new@example.com", "token123")
    html_body = mail.html_part.body.decoded
    text_body = mail.text_part.body.decoded

    assert_includes html_body, "old@example.com"
    assert_includes html_body, "new@example.com"
    assert_includes html_body, "btn-carmine"
    assert_includes text_body, "new@example.com"
  end

  test "verify_email renders subject, recipients, and verification link" do
    mail = AuthMailer.verify_email("verify@example.com", "token789")
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
