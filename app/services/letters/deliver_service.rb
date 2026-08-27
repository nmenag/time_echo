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

      I18n.with_locale(@letter.language.presence || I18n.default_locale) do
        LetterMailer.future_letter(@letter).deliver_now
      end

      @letter.update!(status: "delivered", delivered_at: Time.current)

      Analytics::TrackEventService.call("email_delivered", {
        letter_id: @letter.id,
        email: @letter.email
      })
    end
  end
end
