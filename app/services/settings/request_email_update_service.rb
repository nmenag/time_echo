require "ostruct"

module Settings
  class RequestEmailUpdateService
    def self.call(user_preference, new_email, old_email)
      new(user_preference, new_email, old_email).call
    end

    def initialize(user_preference, new_email, old_email)
      @user_preference = user_preference
      @new_email = new_email&.strip&.downcase
      @old_email = old_email
    end

    def call
      return OpenStruct.new(success?: false, error: "Por favor introduce un correo electrónico válido.") unless valid_email?

      token_record = SessionToken.create!(email: @new_email)
      @user_preference.update!(unconfirmed_email: @new_email)

      AuthMailer.confirm_email_update(@old_email, @new_email, token_record.token).deliver_later
      Analytics::TrackEventService.call("email_update_requested", { old_email: @old_email, new_email: @new_email }) rescue nil

      OpenStruct.new(success?: true)
    end

    private

    def valid_email?
      @new_email.present? && @new_email.match?(URI::MailTo::EMAIL_REGEXP)
    end
  end
end
