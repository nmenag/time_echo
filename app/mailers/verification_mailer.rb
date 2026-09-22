class VerificationMailer < ApplicationMailer
  def confirm_email(old_email, new_email, token)
    @old_email = old_email
    @new_email = new_email
    @confirm_url = confirm_email_update_url(token: token)

    mail(
      to: @new_email,
      subject: t("mailers.confirm_email.subject"),
      tags: [
        { name: "email_type", value: "confirm_email" }
      ]
    )
  end

  def verify_email(email, token)
    @email = email
    @verify_url = verify_email_url(token: token)

    mail(
      to: @email,
      subject: t("mailers.verify_email.subject"),
      tags: [
        { name: "email_type", value: "verify_email" }
      ]
    )
  end

  private

  def confirm_email_update_url(token:)
    Rails.application.routes.url_helpers.confirm_email_update_settings_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end

  def verify_email_url(token:)
    Rails.application.routes.url_helpers.verify_email_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end
end
