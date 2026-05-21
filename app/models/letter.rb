class Letter < ApplicationRecord
  has_many_attached :attachments

  STATUSES = %w[draft pending delivered].freeze

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :content, presence: true
  validates :deliver_at, presence: true
  validates :status, inclusion: { in: STATUSES }

  validate :deliver_at_must_be_in_future, on: :create

  scope :pending, -> { where(status: "pending").where("deliver_at <= ?", Time.current) }
  scope :scheduled, -> { where(status: "pending").where("deliver_at > ?", Time.current) }
  scope :published, -> { where(public: true, status: "delivered").order(delivered_at: :desc) }
  scope :delivered, -> { where(status: "delivered").order(delivered_at: :desc) }
  scope :for_email, ->(email) { where(email: email) }

  def draft?
    status == "draft"
  end

  def pending?
    status == "pending"
  end

  def delivered?
    status == "delivered"
  end

  def countdown_seconds
    return 0 if delivered?
    [(deliver_at - Time.current).to_i, 0].max
  end

  private

  def deliver_at_must_be_in_future
    if deliver_at.present? && deliver_at <= Time.current
      errors.add(:deliver_at, "must be in the future")
    end
  end
end
