class LetterMailer < ApplicationMailer
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

  def stamped_confirmation(letter)
    @letter = letter
    @time_echo_url = Rails.application.routes.url_helpers.root_url(host: ENV.fetch("APP_HOST") { "localhost:3000" })
    locale = @letter.language.presence || I18n.default_locale

    I18n.with_locale(locale) do
      mail(
        to: @letter.email,
        subject: t("mailers.stamped_confirmation.subject", title: @letter.title),
        headers: {
          "X-Letter-ID" => @letter.id.to_s
        },
        tags: [
          { name: "letter_id", value: @letter.id.to_s },
          { name: "email_type", value: "stamped_confirmation" }
        ]
      )
    end
  end
end
