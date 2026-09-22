require "test_helper"

class AuthMailerTest < ActionMailer::TestCase
  test "magic_link" do
    mail = AuthMailer.magic_link("user@example.com", "token123")
    assert_equal [ "user@example.com" ], mail.to
    assert_equal [ "no-reply@timeecho.me" ], mail.from
    assert_equal "TimeEcho <no-reply@timeecho.me>", mail[:from].decoded
    assert_equal I18n.t("mailers.magic_link.subject"), mail.subject
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
end
