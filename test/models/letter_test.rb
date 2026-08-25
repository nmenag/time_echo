require "test_helper"

class LetterTest < ActiveSupport::TestCase
  test "valid letter" do
    letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Hello",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    assert letter.valid?
  end

  test "invalid without title" do
    letter = Letter.new(email: "test@example.com", content: "Hello", deliver_at: 1.year.from_now, status: "pending")
    assert_not letter.valid?
    assert letter.errors[:title].any?
  end

  test "invalid without email" do
    letter = Letter.new(title: "Test", content: "Hello", deliver_at: 1.year.from_now, status: "pending")
    assert_not letter.valid?
    assert letter.errors[:email].any?
  end



  test "pending? returns true for pending status" do
    letter = Letter.new(status: "pending")
    assert letter.pending?
  end

  test "delivered? returns true for delivered status" do
    letter = Letter.new(status: "delivered")
    assert letter.delivered?
  end

  test "failed? returns true for failed status" do
    letter = Letter.new(status: "failed")
    assert letter.failed?
  end

  test "bounced? returns true for bounced status" do
    letter = Letter.new(status: "bounced")
    assert letter.bounced?
  end

  test "countdown_seconds returns 0 for delivered letter" do
    letter = Letter.new(status: "delivered", deliver_at: 1.year.from_now)
    assert_equal 0, letter.countdown_seconds
  end

  test "countdown_seconds returns positive value for pending letter" do
    letter = Letter.new(status: "pending", deliver_at: 1.day.from_now)
    assert letter.countdown_seconds > 0
  end

  test "invalid when deliver_at is in the past on create" do
    letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Hello",
      deliver_at: 1.day.ago,
      status: "pending"
    )
    assert_not letter.valid?
    assert letter.errors[:deliver_at].any?
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
      deliver_at: 1.year.from_now,
      status: "pending",
      language: "fr"
    )
    assert_not letter.valid?
    assert letter.errors[:language].any?
  end
end
