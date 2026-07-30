require "test_helper"

class Letters::AccessServiceTest < ActiveSupport::TestCase
  setup do
    @pending_letter = Letter.new(
      title: "Pending Letter",
      email: "owner@example.com",
      content: "Secret details.",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    @pending_letter.save!(validate: false)

    @delivered_private = Letter.new(
      title: "Private Delivered",
      email: "owner@example.com",
      content: "Secret content.",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered"
    )
    @delivered_private.save!(validate: false)
  end

  test "returns not_found if letter doesn't exist" do
    result = Letters::AccessService.call(999999, "owner@example.com")
    assert_not result.success?
    assert_equal :not_found, result.error
  end

  test "returns not_found if looking up private delivered letter belonging to someone else" do
    result = Letters::AccessService.call(@delivered_private.id, "someone_else@example.com")
    assert_not result.success?
    assert_equal :not_found, result.error
  end

  test "allows access to private delivered letter via owner email" do
    result = Letters::AccessService.call(@delivered_private.id, "owner@example.com")
    assert result.success?
    assert_equal @delivered_private, result.letter
    assert_not result.countdown?
  end

  test "allows access to any letter via signed ID" do
    result = Letters::AccessService.call(@pending_letter.signed_id, "anyone@example.com")
    assert result.success?
    assert_equal @pending_letter, result.letter
    assert result.countdown?
  end

  test "updates opened_at and increments open_count only for delivered letters on first open" do
    assert_nil @delivered_private.opened_at
    assert_equal 0, @delivered_private.open_count

    result = Letters::AccessService.call(@delivered_private.id, "owner@example.com")
    assert result.success?

    @delivered_private.reload
    assert_not_nil @delivered_private.opened_at
    assert_equal 1, @delivered_private.open_count
  end

  test "does not update opened_at for pending letters" do
    assert_nil @pending_letter.opened_at
    result = Letters::AccessService.call(@pending_letter.signed_id, "owner@example.com")
    assert result.success?

    @pending_letter.reload
    assert_nil @pending_letter.opened_at
  end
end
