# frozen_string_literal: true

require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.create!(
      email: "traveler@timeecho.com",
      title: "My Legacy Letter",
      content: "Deep reflections from yesterday.",
      scheduled_at: 1.year.from_now,
      timezone: "America/Bogota"
    )
  end

  test "valid with action" do
    log = AuditLog.new(action: "letter.created", auditable: @letter, actor_email: @letter.email)
    assert log.valid?
  end

  test "invalid without action" do
    log = AuditLog.new(action: nil)
    assert_not log.valid?
    assert_includes log.errors[:action], I18n.t("errors.messages.blank")
  end

  test "is readonly when persisted" do
    log = AuditLog.record!(action: "letter.created", auditable: @letter, actor_email: @letter.email)
    assert log.persisted?
    assert log.readonly?
    assert_raises(ActiveRecord::ReadOnlyRecord) do
      log.update(action: "tampered")
    end
  end

  test "record! captures Current ip_address and user_agent by default" do
    Current.ip_address = "192.168.1.100"
    Current.user_agent = "TimeEcho-Browser/1.0"

    log = AuditLog.record!(
      action: "letter.archived",
      auditable: @letter,
      actor_email: @letter.email,
      metadata: { from_status: "pending", to_status: "archived" }
    )

    assert_equal "192.168.1.100", log.ip_address
    assert_equal "TimeEcho-Browser/1.0", log.user_agent
    assert_equal "letter.archived", log.action
    assert_equal "archived", log.metadata["to_status"]
  ensure
    Current.reset
  end

  test "scopes filter by action, actor and recent order" do
    AuditLog.delete_all

    log1 = AuditLog.record!(action: "letter.created", actor_email: "alpha@timeecho.com")
    log2 = AuditLog.record!(action: "letter.delivered", actor_email: "beta@timeecho.com")

    assert_equal [ log2, log1 ], AuditLog.recent.to_a
    assert_equal [ log1 ], AuditLog.for_action("letter.created").to_a
    assert_equal [ log2 ], AuditLog.for_actor("beta@timeecho.com").to_a
  end
end
