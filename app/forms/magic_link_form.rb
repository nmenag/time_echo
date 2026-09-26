class MagicLinkForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :request_limit_not_exceeded

  def submit
    return false unless valid?

    Auth::MagicLinkService.generate_and_send(email)
    true
  end

  private

  def request_limit_not_exceeded
    return if email.blank?

    normalized_email = email.strip.downcase
    if SessionToken.where(email: normalized_email).where("created_at >= ?", 1.hour.ago).count >= 5
      errors.add(:base, I18n.t("errors.messages.magic_link_rate_limit_exceeded"))
    end
  end
end
