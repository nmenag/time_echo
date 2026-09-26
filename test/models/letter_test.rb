require "test_helper"

class LetterTest < ActiveSupport::TestCase
  test "valid letter" do
    letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Hello",
      scheduled_at: 1.year.from_now,
      timezone: "America/Bogota",
      status: "pending"
    )
    assert letter.valid?
  end

  test "invalid without title" do
    letter = Letter.new(email: "test@example.com", content: "Hello", scheduled_at: 1.year.from_now, status: "pending")
    assert_not letter.valid?
    assert letter.errors[:title].any?
  end

  test "invalid without email" do
    letter = Letter.new(title: "Test", content: "Hello", scheduled_at: 1.year.from_now, status: "pending")
    assert_not letter.valid?
    assert letter.errors[:email].any?
  end

  test "pending? returns true for pending status" do
    letter = Letter.new(status: "pending")
    assert letter.pending?
  end

  test "queued? returns true for queued status" do
    letter = Letter.new(status: "queued")
    assert letter.queued?
  end

  test "delivered? returns true for delivered status" do
    letter = Letter.new(status: "delivered")
    assert letter.delivered?
  end

  test "failed? returns true for failed status" do
    letter = Letter.new(status: "failed")
    assert letter.failed?
  end

  test "countdown_seconds returns 0 for delivered letter" do
    letter = Letter.new(status: "delivered", scheduled_at: 1.year.from_now)
    assert_equal 0, letter.countdown_seconds
  end

  test "countdown_seconds returns positive value for pending letter" do
    letter = Letter.new(status: "pending", scheduled_at: 1.day.from_now)
    assert letter.countdown_seconds > 0
  end

  test "invalid when scheduled_at is in the past on create" do
    letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Hello",
      scheduled_at: 1.day.ago,
      status: "pending"
    )
    assert_not letter.valid?
    assert letter.errors[:scheduled_at].any?
  end

  test "invalid with bad IANA timezone" do
    letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Hello",
      scheduled_at: 1.year.from_now,
      timezone: "Invalid/Timezone",
      status: "pending"
    )
    assert_not letter.valid?
    assert letter.errors[:timezone].any?
  end

  test "local_scheduled_at converts UTC scheduled_at to target timezone" do
    utc_time = Time.utc(2027, 5, 20, 15, 0, 0)
    letter = Letter.new(
      scheduled_at: utc_time,
      timezone: "America/Bogota"
    )

    local_time = letter.local_scheduled_at
    assert_equal "America/Bogota", local_time.time_zone.name
    assert_equal 10, local_time.hour # UTC 15:00 is 10:00 in Bogota (-5)
  end

  test "defaults language to current I18n.locale" do
    I18n.with_locale(:es) do
      letter = Letter.new
      assert_equal "es", letter.language
    end
  end

  test "invalid with unsupported language" do
    letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Hello",
      scheduled_at: 1.year.from_now,
      status: "pending",
      language: "fr"
    )
    assert_not letter.valid?
    assert letter.errors[:language].any?
  end

  test "archived? returns true for archived status" do
    letter = Letter.new(status: "archived")
    assert letter.archived?
  end

  test "countdown_seconds returns 0 for archived letter" do
    letter = Letter.new(status: "archived", scheduled_at: 1.year.from_now)
    assert_equal 0, letter.countdown_seconds
  end

  test "active and archived scopes filter correctly" do
    active_letter = Letter.new(
      title: "Active",
      email: "active@example.com",
      content: "Active",
      scheduled_at: 1.year.from_now,
      status: "pending"
    )
    active_letter.save!(validate: false)

    archived_letter = Letter.new(
      title: "Archived",
      email: "archived@example.com",
      content: "Archived",
      scheduled_at: 1.year.from_now,
      status: "archived"
    )
    archived_letter.save!(validate: false)

    assert_includes Letter.active, active_letter
    assert_not_includes Letter.active, archived_letter
    assert_includes Letter.archived, archived_letter
    assert_not_includes Letter.archived, active_letter
  end

  test "delivered letter cannot be archived or transitioned to pending" do
    letter = Letter.new(
      title: "Delivered Letter",
      email: "test@example.com",
      content: "Delivered",
      scheduled_at: 1.year.ago,
      delivered_at: 1.year.ago,
      status: "delivered"
    )
    letter.save!(validate: false)

    assert_not letter.can_archive?
    assert_not letter.can_transition_to?("pending")
    assert_not letter.can_transition_to?("archived")

    assert_raises(LetterStateMachine::InvalidTransitionError) do
      letter.archive!
    end

    assert_raises(LetterStateMachine::InvalidTransitionError) do
      letter.restore!
    end

    letter.status = "archived"
    assert_not letter.valid?
    assert_includes letter.errors[:status], "cannot transition from 'delivered' to 'archived'"

    letter.status = "pending"
    assert_not letter.valid?
    assert_includes letter.errors[:status], "cannot transition from 'delivered' to 'pending'"
  end

  test "archived letter can only be restored to pending" do
    letter = Letter.new(
      title: "Archived Letter",
      email: "test@example.com",
      content: "Archived",
      scheduled_at: 1.year.from_now,
      status: "archived"
    )
    letter.save!(validate: false)

    assert letter.can_restore?
    assert letter.can_transition_to?("pending")
    assert_not letter.can_transition_to?("delivered")
    assert_not letter.can_transition_to?("queued")

    letter.restore!
    assert_equal "pending", letter.reload.status
  end

  test "can_queue?, can_deliver?, and deliver! transitions" do
    letter = Letter.new(
      title: "Queueable Letter",
      email: "test@example.com",
      content: "Queued",
      scheduled_at: 1.year.from_now,
      status: "pending"
    )
    letter.save!(validate: false)

    assert letter.can_queue?
    assert letter.can_deliver?

    letter.deliver!
    assert_equal "delivered", letter.reload.status
    assert_not_nil letter.delivered_at

    assert_raises(LetterStateMachine::InvalidTransitionError) do
      letter.deliver!
    end
  end
end
