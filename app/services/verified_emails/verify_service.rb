module VerifiedEmails
  class VerifyService
    def self.call(token)
      new(token).call
    end

    def initialize(token)
      @token = token
    end

    def call
      return Result.new(success: false) if @token.blank?

      verified_email = VerifiedEmail.find_by(token: @token)
      return Result.new(success: false) unless verified_email&.token_valid?

      verified_email.verify!
      Analytics::TrackEventService.call("email_verified", { email: verified_email.email })

      Result.new(success: true, verified_email: verified_email)
    end

    class Result
      attr_reader :verified_email

      def initialize(success:, verified_email: nil)
        @success = success
        @verified_email = verified_email
      end

      def success?
        @success
      end
    end
  end
end
