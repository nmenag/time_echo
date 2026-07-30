module Auth
  class MagicLinkService
    def self.generate_and_send(email)
      token_record = SessionToken.create!(email: email)
      TimeCapsuleMailer.magic_link(email, token_record.token).deliver_later
      token_record
    end

    def self.authenticate(token)
      token_record = SessionToken.active.find_by(token: token)
      return nil unless token_record

      token_record.use!
      token_record.email
    end
  end
end
