require "test_helper"

class LetterDecoratorTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.new(
      title: "Test Letter",
      email: "test@example.com",
      content: "Hello",
      created_at: Time.zone.local(2026, 1, 1),
      deliver_at: Time.zone.local(2026, 1, 2),
      delivered_at: Time.zone.local(2026, 1, 2),
      status: "pending"
    )
    @decorator = LetterDecorator.new(@letter)
  end

  test "formats dates and days left" do
    assert_not_nil @decorator.formatted_created_at
    assert_not_nil @decorator.formatted_delivered_at
    assert_not_nil @decorator.formatted_deliver_at

    nil_letter = LetterDecorator.new(Letter.new)
    assert_nil nil_letter.formatted_delivered_at
    assert_nil nil_letter.formatted_deliver_at

    assert_kind_of Integer, @decorator.days_left
    assert_kind_of String, @decorator.days_left_text

    @letter.deliver_at = Date.current + 1.day
    assert_equal "1 día", @decorator.days_left_text
  end

  test "returns correct status badge" do
    assert_equal "Cápsula en tránsito ⏳", @decorator.status_badge
    @letter.status = "delivered"
    assert_equal "Cápsula desbloqueada ✨", @decorator.status_badge
  end

  test "decorates collection via ApplicationDecorator" do
    collection = LetterDecorator.decorate([ @letter ])
    assert_kind_of Array, collection
    assert_kind_of LetterDecorator, collection.first

    single = ApplicationDecorator.decorate(@letter)
    assert_kind_of ApplicationDecorator, single
  end

  test "decorates predictions" do
    @letter.save!(validate: false)
    @letter.predictions.create!(category: "city", prediction: "Madrid")
    decorated = @decorator.decorated_predictions
    assert_kind_of Array, decorated
    assert_kind_of PredictionDecorator, decorated.first
  end
end
