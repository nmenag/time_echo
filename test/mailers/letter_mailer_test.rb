require "test_helper"

class LetterMailerTest < ActionMailer::TestCase
  test "future_letter uses letter locale" do
    letter = Letter.new(
      title: "Test",
      email: "user@example.com",
      content: "Hello",
      deliver_at: 1.day.ago,
      status: "delivered",
      language: "es"
    )
    letter.save!(validate: false)

    I18n.with_locale(:en) do
      mail = LetterMailer.future_letter(letter)
      assert_equal [ "user@example.com" ], mail.to
      spanish_subject = I18n.with_locale(:es) { I18n.t("mailers.future_letter.subject", date: I18n.l(letter.created_at.to_date, format: :long)) }
      assert_equal spanish_subject, mail.subject
    end
  end
end
