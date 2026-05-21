class TimeCapsuleMailer < ApplicationMailer
  default from: "TimeEcho <no-reply@timeecho.com>"

  def magic_link(email, token)
    @email = email
    @magic_link_url = magic_login_url(token: token)

    mail(
      to: @email,
      subject: "Your Magic Sign-In Link for TimeEcho",
      resend_data: {
        tags: [
          { name: "email_type", value: "magic_link" }
        ]
      }
    )
  end

  def future_letter(letter)
    @letter = letter

    # If there are attachments, attach them to the Action Mailer email
    if @letter.attachments.attached?
      @letter.attachments.each do |attachment|
        attachments[attachment.filename.to_s] = attachment.download
      end
    end

    mail(
      to: @letter.email,
      subject: "A Message from Your Past Self (Sent #{@letter.created_at.strftime('%B %d, %Y')})",
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
