# frozen_string_literal: true

require "test_helper"

class LetterPolicyTest < ActiveSupport::TestCase
  setup do
    @owner_email = "owner@example.com"
    @other_email = "other@example.com"
    @letter = Letter.new(
      title: "Capsule",
      email: @owner_email,
      content: "Deep thoughts",
      scheduled_at: 1.year.from_now,
      status: "pending"
    )
    @letter.save!(validate: false)
  end

  test "permits show, archive, and restore when user is the owner" do
    policy = LetterPolicy.new(@owner_email, @letter)

    assert policy.show?
    assert policy.archive?
    assert policy.restore?
  end

  test "denies show, archive, and restore when user email does not match letter owner" do
    policy = LetterPolicy.new(@other_email, @letter)

    assert_not policy.show?
    assert_not policy.archive?
    assert_not policy.restore?
  end

  test "denies show, archive, and restore when user email is nil or empty" do
    nil_policy = LetterPolicy.new(nil, @letter)
    assert_not nil_policy.show?
    assert_not nil_policy.archive?
    assert_not nil_policy.restore?

    empty_policy = LetterPolicy.new("", @letter)
    assert_not empty_policy.show?
    assert_not empty_policy.archive?
    assert_not empty_policy.restore?
  end
end
