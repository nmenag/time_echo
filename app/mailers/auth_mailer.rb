class AuthMailer < ApplicationMailer
  def magic_link(email, token)
    @email = email
    @magic_link_url = magic_login_url(token: token)

    mail(
      to: @email,
      subject: t("mailers.magic_link.subject"),
      tags: [
        { name: "email_type", value: "magic_link" }
      ]
    )
  end

  def confirm_email_update(old_email, new_email, token)
    @old_email = old_email
    @new_email = new_email
    @confirm_url = confirm_email_update_url(token: token)

    mail(
      to: @new_email,
      subject: t("mailers.confirm_email_update.subject"),
      tags: [
        { name: "email_type", value: "confirm_email_update" }
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

  def magic_login_url(token:)
    Rails.application.routes.url_helpers.magic_login_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end

  def confirm_email_update_url(token:)
    Rails.application.routes.url_helpers.confirm_email_update_settings_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end

  def verify_email_url(token:)
    Rails.application.routes.url_helpers.verify_email_url(token: token, host: ENV.fetch("APP_HOST") { "localhost:3000" })
  end
end
