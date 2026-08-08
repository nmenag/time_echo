require "test_helper"

class LetterDecoratorTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.create!(
      title: "Test",
      email: "test@example.com",
      content: "Content",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
  end

  test "formatted_created_at returns formatted date" do
    decorator = LetterDecorator.new(@letter)
    assert_match /\d+ de \w+ de \d{4}/, decorator.formatted_created_at
  end

  test "formatted_delivered_at returns nil when not delivered" do
    decorator = LetterDecorator.new(@letter)
    assert_nil decorator.formatted_delivered_at
  end

  test "formatted_delivered_at returns formatted date when delivered" do
    letter = Letter.new(
      title: "Delivered",
      email: "test@example.com",
      content: "Content",
      deliver_at: 1.year.ago,
      status: "delivered",
      delivered_at: 1.day.ago
    )
    letter.save!(validate: false)
    decorator = LetterDecorator.new(letter)
    assert_match /\d+ de \w+ de \d{4}/, decorator.formatted_delivered_at
  end

  test "days_left returns positive number for pending letter" do
    decorator = LetterDecorator.new(@letter)
    assert decorator.days_left > 0
  end

  test "days_left_text returns correct text" do
    decorator = LetterDecorator.new(@letter)
    assert_match /\d+ días/, decorator.days_left_text
  end

  test "status_badge returns en_transit for pending" do
    decorator = LetterDecorator.new(@letter)
    assert_equal "Cápsula en tránsito ⏳", decorator.status_badge
  end

  test "status_badge returns unlocked for delivered" do
    @letter.update!(status: "delivered", delivered_at: Time.current)
    decorator = LetterDecorator.new(@letter)
    assert_equal "Cápsula desbloqueada ✨", decorator.status_badge
  end

  test "decorated_predictions returns decorated predictions" do
    @letter.predictions.create!(category: "city", prediction: "Bogotá")
    decorator = LetterDecorator.new(@letter)
    decorated = decorator.decorated_predictions
    assert_equal 1, decorated.size
    assert_kind_of PredictionDecorator, decorated.first
  end
end
