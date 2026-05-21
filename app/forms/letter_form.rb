class LetterForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :content, :string
  attribute :deliver_at, :datetime
  attribute :public, :boolean, default: false
  attribute :attachments

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :content, presence: true
  validates :deliver_at, presence: true
  validate :deliver_at_must_be_in_future

  attr_reader :letter

  def save
    return false unless valid?

    Letter.transaction do
      @letter = Letter.new(
        email: email,
        content: content,
        deliver_at: deliver_at,
        public: public,
        status: "pending"
      )

      if attachments.present?
        @letter.attachments.attach(attachments)
      end

      @letter.save!
      # Track event
      Analytics::TrackEventService.call("letter_created", { email: email, public: public })
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  private

  def deliver_at_must_be_in_future
    if deliver_at.present? && deliver_at <= Time.current
      errors.add(:deliver_at, "must be in the future")
    end
  end
end
