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
end
