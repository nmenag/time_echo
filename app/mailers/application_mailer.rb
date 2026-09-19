class ApplicationMailer < ActionMailer::Base
  default from: -> { default_from_address }
  layout "mailer"

  private

  def default_from_address
    sender = ENV.fetch("MAILER_SENDER") { ENV.fetch("MAILER_FROM", "TimeEcho <no-reply@timeecho.me>") }
    sender.include?("<") ? sender : "TimeEcho <#{sender}>"
  end
end
