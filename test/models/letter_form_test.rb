require "test_helper"

class LetterFormTest < ActiveSupport::TestCase
  test "valid letter form creates letter, emotional snapshot, and predictions" do
    params = {
      title: "My Future self",
      email: "test@example.com",
      content: "Hello from the past!",
      deliver_at: 1.year.from_now,
      happiness_level: 7,
      anxiety_level: 3,
      motivation_level: 8,
      prediction_city: "Madrid",
      prediction_salary: "$90,000",
      prediction_relationship: "married",
      prediction_career: "Tech Lead",
      prediction_achievement: "run a marathon"
    }

    form = LetterForm.new(params)

    assert form.valid?
    assert_difference -> { Letter.count } => 1, -> { EmotionalSnapshot.count } => 1, -> { Prediction.count } => 6 do
      assert form.save
    end

    letter = form.letter
    assert_equal "My Future self", letter.title
    assert_equal "test@example.com", letter.email
    assert_equal "Hello from the past!", letter.content
    assert_equal "pending", letter.status

    # Verify emotional snapshot
    snapshot = letter.emotional_snapshot
    assert_not_nil snapshot
    assert_equal 7, snapshot.happiness_level
    assert_equal 3, snapshot.anxiety_level
    assert_equal 8, snapshot.motivation_level

    # Verify predictions
    predictions = letter.predictions
    assert_equal 6, predictions.size
    assert_equal "Madrid", predictions.find_by(category: "city").prediction
    assert_equal "$90,000", predictions.find_by(category: "salary").prediction
  end

  test "invalid letter form validations" do
    # 1. Past deliver_at
    form = LetterForm.new(
      title: "Title",
      email: "user@example.com",
      content: "Content",
      deliver_at: 1.day.ago
    )
    assert_not form.valid?
    assert form.errors[:deliver_at].any?

    # 2. Missing title
    form = LetterForm.new(
      email: "user@example.com",
      content: "Content",
      deliver_at: 1.year.from_now
    )
    assert_not form.valid?
    assert form.errors[:title].any?

    # 3. Invalid email format
    form = LetterForm.new(
      title: "Title",
      email: "not-an-email",
      content: "Content",
      deliver_at: 1.year.from_now
    )
    assert_not form.valid?
    assert form.errors[:email].any?

    # 4. Out of bounds emotional levels
    form = LetterForm.new(
      title: "Title",
      email: "user@example.com",
      content: "Content",
      deliver_at: 1.year.from_now,
      happiness_level: 11
    )
    assert_not form.valid?
    assert form.errors[:happiness_level].any?
  end

  test "handles ActiveRecord::RecordInvalid on save" do
    form = LetterForm.new(
      title: "Title",
      email: "user@example.com",
      content: "Content",
      deliver_at: 1.year.from_now
    )

    fake_letter = Letter.new
    def fake_letter.save!
      raise ActiveRecord::RecordInvalid.new(Letter.new)
    end

    original_new = Letter.method(:new)
    Letter.define_singleton_method(:new, ->(attrs = {}) { fake_letter })

    assert_not form.save
    assert form.errors[:base].any?
  ensure
    Letter.define_singleton_method(:new, original_new.to_proc) if original_new
  end
end
