require "ostruct"

module Settings
  class ConfirmEmailUpdateService
    def self.call(token)
      new(token).call
    end

    def initialize(token)
      @token = token
    end

    def call
      token_record = SessionToken.active.find_by(token: @token)
      return OpenStruct.new(success?: false) unless token_record

      new_email = token_record.email
      pref = UserPreference.find_by(unconfirmed_email: new_email)
      return OpenStruct.new(success?: false) unless pref

      old_email = pref.email

      ActiveRecord::Base.transaction do
        token_record.use!

        existing_pref = UserPreference.find_by(email: new_email)
        Letter.where(email: old_email).update_all(email: new_email)

        existing_pref.destroy! if existing_pref
        pref.update!(email: new_email, unconfirmed_email: nil)
      end

      Analytics::TrackEventService.call("email_update_confirmed", { old_email: old_email, new_email: new_email }) rescue nil

      OpenStruct.new(success?: true, new_email: new_email)
    end
  end
end
