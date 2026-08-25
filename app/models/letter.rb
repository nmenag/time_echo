class Letter < ApplicationRecord
  encrypts :title
  encrypts :content
  has_many :predictions, dependent: :destroy
  has_one :emotional_snapshot, dependent: :destroy

  STATUSES = %w[pending delivered failed bounced].freeze

  attribute :language, :string, default: -> { I18n.locale.to_s }

  validates :title, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :content, presence: true
  validates :deliver_at, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :language, presence: true, inclusion: { in: I18n.available_locales.map(&:to_s) }
  validates :reveal_happiness, :reveal_anxiety, :reveal_motivation, numericality: { only_integer: true, in: 1..10 }, allow_nil: true

  validate :deliver_at_must_be_in_future, on: :create

  scope :pending, -> { where(status: "pending").where("deliver_at <= ?", Time.current) }
  scope :scheduled, -> { where(status: "pending").where("deliver_at > ?", Time.current) }
  scope :delivered, -> { where(status: "delivered").order(delivered_at: :desc) }
  scope :for_email, ->(email) { where(email: email) }

  def pending?
    status == "pending"
  end

  def delivered?
    status == "delivered"
  end

  def failed?
    status == "failed"
  end

  def bounced?
    status == "bounced"
  end

  def countdown_seconds
    return 0 if delivered?
    [ (deliver_at - Time.current).to_i, 0 ].max
  end

  private

  def deliver_at_must_be_in_future
    if deliver_at.present? && deliver_at <= Time.current
      errors.add(:deliver_at, "must be in the future")
    end
  end
end
