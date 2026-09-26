class VerifiedEmail < ApplicationRecord
  before_validation :normalize_email

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }

  scope :verified, -> { where.not(verified_at: nil) }
  scope :unverified, -> { where(verified_at: nil) }

  def self.verified?(email)
    return false if email.blank?

    where("lower(email) = ?", email.to_s.strip.downcase).where.not(verified_at: nil).exists?
  end

  def self.verify!(email)
    return nil if email.blank?

    record = find_or_initialize_by(email: email.to_s.strip.downcase)
    record.verify!
    record
  end

  def self.generate_token_for(email)
    return nil if email.blank?

    record = find_or_initialize_by(email: email.to_s.strip.downcase)
    record.generate_token! unless record.verified?
    record
  end

  def verified?
    verified_at.present?
  end

  def verify!
    update!(verified_at: Time.current, token: nil, token_expires_at: nil)
  end

  def generate_token!
    update!(token: SecureRandom.hex(24), token_expires_at: 48.hours.from_now)
  end

  def token_valid?
    token.present? && token_expires_at.present? && token_expires_at > Time.current
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
