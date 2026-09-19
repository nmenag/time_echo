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

  test "future_letter uses dynamic default from address" do
    letter = Letter.new(
      title: "Test",
      email: "user@example.com",
      content: "Hello",
      deliver_at: 1.day.ago,
      status: "delivered",
      language: "en"
    )
    letter.save!(validate: false)

    mail = LetterMailer.future_letter(letter)
    assert_equal [ "no-reply@timeecho.me" ], mail.from
    assert_equal "TimeEcho <no-reply@timeecho.me>", mail[:from].decoded
  end

  test "future_letter dynamically adapts to MAILER_SENDER environment variable" do
    letter = Letter.new(
      title: "Test",
      email: "user@example.com",
      content: "Hello",
      deliver_at: 1.day.ago,
      status: "delivered",
      language: "en"
    )
    letter.save!(validate: false)

    original_sender = ENV["MAILER_SENDER"]
    begin
      ENV["MAILER_SENDER"] = "letters@timeecho.me"
      mail = LetterMailer.future_letter(letter)
      assert_equal [ "letters@timeecho.me" ], mail.from
      assert_equal "TimeEcho <letters@timeecho.me>", mail[:from].decoded

      ENV["MAILER_SENDER"] = "TimeEcho Letters <letters@timeecho.me>"
      mail = LetterMailer.future_letter(letter)
      assert_equal [ "letters@timeecho.me" ], mail.from
      assert_equal "TimeEcho Letters <letters@timeecho.me>", mail[:from].decoded
    ensure
      ENV["MAILER_SENDER"] = original_sender
    end
  end

  test "future_letter renders postal layout and carmine button" do
    letter = Letter.new(
      title: "Letter to Future Me",
      email: "user@example.com",
      content: "A secret reflection for later",
      deliver_at: 1.day.ago,
      status: "delivered",
      language: "en"
    )
    letter.save!(validate: false)

    mail = LetterMailer.future_letter(letter)
    html_body = mail.html_part.body.decoded
    text_body = mail.text_part.body.decoded

    assert_includes html_body, "TimeEcho"
    assert_includes html_body, "btn-carmine"
    assert_includes html_body, "A secret reflection for later"
    assert_includes text_body, "A secret reflection for later"
  end
end
