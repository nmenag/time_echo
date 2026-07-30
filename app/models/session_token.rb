class SessionToken < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where("expires_at > ?", Time.current).where(used_at: nil) }

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  def expired?
    expires_at <= Time.current
  end

  def used?
    used_at.present?
  end

  def use!
    update!(used_at: Time.current)
  end

  private

  def generate_token
    self.token ||= SecureRandom.hex(24)
  end

  def set_expiration
    self.expires_at ||= 15.minutes.from_now
  end
end
