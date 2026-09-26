# frozen_string_literal: true

class AuditLog < ApplicationRecord
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_action, ->(action) { where(action: action) }
  scope :for_actor, ->(email) { where(actor_email: email) }

  def readonly?
    persisted?
  end

  def self.record!(action:, auditable: nil, actor_email: nil, metadata: {}, ip_address: nil, user_agent: nil)
    resolved_ip = ip_address || Current.ip_address
    resolved_ua = user_agent || Current.user_agent

    create!(
      action: action,
      auditable: auditable,
      actor_email: actor_email,
      metadata: metadata,
      ip_address: resolved_ip,
      user_agent: resolved_ua
    )
  end
end
