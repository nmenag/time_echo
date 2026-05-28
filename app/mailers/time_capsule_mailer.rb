class TimeCapsuleMailer < ApplicationMailer
  default from: "TimeEcho <no-reply@timeecho.com>"

  def magic_link(email, token)
    @email = email
    @magic_link_url = magic_login_url(token: token)

    mail(
      to: @email,
      subject: t("mailers.magic_link.subject"),
      resend_data: {
        tags: [
          { name: "email_type", value: "magic_link" }
        ]
      }
    )
  end

  def future_letter(letter)
    @letter = letter

    mail(
      to: @letter.email,
      subject: t("mailers.future_letter.subject", date: I18n.l(@letter.created_at.to_date, format: :long)),
      headers: {
        "X-Letter-ID" => @letter.id.to_s
      },
      resend_data: {
        tags: [
          { name: "letter_id", value: @letter.id.to_s },
          { name: "email_type", value: "future_letter" }
        ]
      }
    )
  end

  private

  def magic_login_url(token:)
    # We will define the route for magic login
    Rails.application.routes.url_helpers.magic_login_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end
end
