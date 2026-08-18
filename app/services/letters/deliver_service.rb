module Letters
  class DeliverService
    def self.call(letter)
      new(letter).call
    end

    def initialize(letter)
      @letter = letter
    end

    def call
      return if @letter.delivered?

      Letter.transaction do
        @letter.update!(
          status: "delivered",
          delivered_at: Time.current,
          delivery_status: "delivered"
        )

        I18n.with_locale(@letter.language.presence || I18n.default_locale) do
          TimeCapsuleMailer.future_letter(@letter).deliver_now
        end

        Analytics::TrackEventService.call("email_delivered", {
          letter_id: @letter.id,
          email: @letter.email
        })
      end
    rescue => e
      @letter.update(delivery_status: "failed")
      Analytics::TrackEventService.call("delivery_failed", {
        letter_id: @letter.id,
        email: @letter.email,
        error: e.message
      })
      raise e
    end
  end
end
