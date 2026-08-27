class LetterMailer < ApplicationMailer
  default from: "TimeEcho <onboarding@resend.dev>"

  def future_letter(letter)
    @letter = letter
    locale = @letter.language.presence || I18n.default_locale

    I18n.with_locale(locale) do
      mail(
        to: @letter.email,
        subject: t("mailers.future_letter.subject", date: I18n.l((@letter.created_at || Time.current).to_date, format: :long)),
        headers: {
          "X-Letter-ID" => @letter.id.to_s
        },
        tags: [
          { name: "letter_id", value: @letter.id.to_s },
          { name: "email_type", value: "future_letter" }
        ]
      )
    end
  end
end
