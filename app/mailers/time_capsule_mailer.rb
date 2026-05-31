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

  def confirm_email_update(old_email, new_email, token)
    @old_email = old_email
    @new_email = new_email
    @confirm_url = confirm_email_update_url(token: token)

    mail(
      to: @new_email,
      subject: t("mailers.confirm_email_update.subject"),
      resend_data: {
        tags: [
          { name: "email_type", value: "confirm_email_update" }
        ]
      }
    )
  end

  private

  def magic_login_url(token:)
    Rails.application.routes.url_helpers.magic_login_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end

  def confirm_email_update_url(token:)
    Rails.application.routes.url_helpers.confirm_email_update_settings_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end
end
