class AnalyticsEvent < ApplicationRecord
  validates :event_type, presence: true
  validates :occurred_at, presence: true

  before_validation :set_occurred_at, on: :create

  scope :by_type, ->(type) { where(event_type: type) }

  private

  def set_occurred_at
    self.occurred_at ||= Time.current
  end
end
