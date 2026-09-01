require "test_helper"

class LetterDecoratorTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Content",
      scheduled_at: 1.year.from_now,
      timezone: "America/Bogota",
      status: "pending"
    )
    @letter.save!(validate: false)
  end

  test "formatted_created_at returns formatted date" do
    decorator = LetterDecorator.new(@letter)
    assert_not_nil decorator.formatted_created_at
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
      scheduled_at: 1.year.ago,
      timezone: "America/Bogota",
      status: "delivered",
      delivered_at: 1.day.ago
    )
    letter.save!(validate: false)
    decorator = LetterDecorator.new(letter)
    assert_not_nil decorator.formatted_delivered_at
  end

  test "formatted_deliver_at formats localized date in letter timezone" do
    utc_time = Time.utc(2027, 5, 20, 23, 0, 0)
    letter = Letter.new(
      scheduled_at: utc_time,
      timezone: "America/Bogota"
    )
    decorator = LetterDecorator.new(letter)
    # May 20 23:00 UTC is May 20 18:00 in Bogota (-5)
    assert_equal "2027-05-20", decorator.local_scheduled_at.to_date.to_s
  end

  test "days_left returns positive number for pending letter" do
    decorator = LetterDecorator.new(@letter)
    assert decorator.days_left > 0
  end

  test "days_left_text returns correct text" do
    decorator = LetterDecorator.new(@letter)
    assert_match /\d+/, decorator.days_left_text
  end

  test "status_badge returns en_transit for pending" do
    decorator = LetterDecorator.new(@letter)
    assert_match /⏳/, decorator.status_badge
  end

  test "status_badge returns unlocked for delivered" do
    @letter.update!(status: "delivered", delivered_at: Time.current)
    decorator = LetterDecorator.new(@letter)
    assert_match /✨/, decorator.status_badge
  end

  test "decorated_predictions returns decorated predictions" do
    @letter.predictions.create!(category: "city", prediction: "Bogotá")
    decorator = LetterDecorator.new(@letter)
    decorated = decorator.decorated_predictions
    assert_equal 1, decorated.size
    assert_kind_of PredictionDecorator, decorated.first
  end

  test "display_title translates sentinel key to current locale" do
    letter = Letter.new(
      title: "your_letter",
      email: "test@example.com",
      content: "Content",
      scheduled_at: 1.year.from_now,
      timezone: "America/Bogota",
      status: "pending"
    )
    letter.save!(validate: false)
    decorator = LetterDecorator.new(letter)
    assert_equal "Tu carta", decorator.display_title
  end

  test "display_title returns custom title as-is" do
    decorator = LetterDecorator.new(@letter)
    assert_equal "Test", decorator.display_title
  end

  test "display_title translates legacy English title" do
    letter = Letter.new(
      title: "Your letter",
      email: "test@example.com",
      content: "Content",
      scheduled_at: 1.year.from_now,
      timezone: "America/Bogota",
      status: "pending"
    )
    letter.save!(validate: false)
    decorator = LetterDecorator.new(letter)
    assert_equal "Tu carta", decorator.display_title
  end
end
