require "test_helper"

class PredictionDecoratorTest < ActiveSupport::TestCase
  setup do
    @letter = Letter.new(
      title: "Test",
      email: "test@example.com",
      content: "Content",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    @letter.save!(validate: false)
    @prediction = @letter.predictions.create!(category: "city", prediction: "Bogotá")
  end

  test "category_label returns correct label for city" do
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "🏠 Ubicación", decorator.category_label
  end

  test "category_label returns fallback for unknown category" do
    @prediction.update_column(:category, "unknown")
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "🔮 Unknown", decorator.category_label
  end

  test "category_label returns correct label for career" do
    @prediction.update!(category: "career")
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "💼 Trabajo / Carrera", decorator.category_label
  end

  test "category_label returns correct label for salary" do
    @prediction.update!(category: "salary")
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "💵 Ingresos", decorator.category_label
  end

  test "category_label returns correct label for relationship" do
    @prediction.update!(category: "relationship")
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "❤️ Relación sentimental", decorator.category_label
  end

  test "category_label returns correct label for achievement" do
    @prediction.update!(category: "achievement")
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "🏆 Mayor logro", decorator.category_label
  end

  test "category_label returns correct label for happiness" do
    @prediction.update!(category: "happiness")
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "😊 Felicidad", decorator.category_label
  end

  test "result_badge returns superaste for salary when matched" do
    @prediction.update!(category: "salary", matched: true)
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "Superaste 🚀", decorator.result_badge
  end

  test "result_badge returns no_acertaste for salary when not matched" do
    @prediction.update!(category: "salary", matched: false)
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "No acertaste ❌", decorator.result_badge
  end

  test "result_badge returns lo_lograste for matched city" do
    @prediction.update!(category: "city", matched: true)
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "Lo lograste! 🎉", decorator.result_badge
  end

  test "result_badge returns parcialmente for not matched city" do
    @prediction.update!(category: "city", matched: false)
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "Parcialmente ➖", decorator.result_badge
  end

  test "result_badge_class returns correct class for matched" do
    @prediction.update!(matched: true)
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "bg-emerald-500 text-white", decorator.result_badge_class
  end

  test "result_badge_class returns amber for not matched city" do
    @prediction.update!(category: "city", matched: false)
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "bg-amber-500 text-white", decorator.result_badge_class
  end

  test "result_badge_class returns violet for not matched salary" do
    @prediction.update!(category: "salary", matched: false)
    decorator = PredictionDecorator.new(@prediction)
    assert_equal "bg-violet-900 text-white", decorator.result_badge_class
  end
end
