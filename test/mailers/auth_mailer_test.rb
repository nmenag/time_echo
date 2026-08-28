require "test_helper"

class AuthMailerTest < ActionMailer::TestCase
  test "magic_link" do
    mail = AuthMailer.magic_link("user@example.com", "token123")
    assert_equal [ "user@example.com" ], mail.to
    assert_equal I18n.t("mailers.magic_link.subject"), mail.subject
  end

  test "confirm_email_update" do
    mail = AuthMailer.confirm_email_update("old@example.com", "new@example.com", "token123")
    assert_equal [ "new@example.com" ], mail.to
    assert_equal I18n.t("mailers.confirm_email_update.subject"), mail.subject
  end
end
