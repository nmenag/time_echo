require "test_helper"

class PredictionDecoratorTest < ActiveSupport::TestCase
  test "category_label returns expected string for categories" do
    categories = {
      "city" => "🏠 Ubicación",
      "career" => "💼 Trabajo / Carrera",
      "salary" => "💵 Ingresos",
      "relationship" => "❤️ Relación sentimental",
      "achievement" => "🏆 Mayor logro",
      "happiness" => "😊 Felicidad",
      "other" => "🔮 Other"
    }

    categories.each do |cat, expected|
      pred = Prediction.new(category: cat)
      decorator = PredictionDecorator.new(pred)
      assert_equal expected, decorator.category_label
    end
  end

  test "result_badge and class when matched" do
    pred_salary = PredictionDecorator.new(Prediction.new(category: "salary", matched: true))
    assert_equal "Superaste 🚀", pred_salary.result_badge
    assert_equal "bg-emerald-500 text-white", pred_salary.result_badge_class

    pred_city = PredictionDecorator.new(Prediction.new(category: "city", matched: true))
    assert_equal "Lo lograste! 🎉", pred_city.result_badge
    assert_equal "bg-emerald-500 text-white", pred_city.result_badge_class
  end

  test "result_badge and class when not matched" do
    pred_city = PredictionDecorator.new(Prediction.new(category: "city", matched: false))
    assert_equal "Parcialmente ➖", pred_city.result_badge
    assert_equal "bg-amber-500 text-white", pred_city.result_badge_class

    pred_other = PredictionDecorator.new(Prediction.new(category: "salary", matched: false))
    assert_equal "No acertaste ❌", pred_other.result_badge
    assert_equal "bg-violet-900 text-white", pred_other.result_badge_class
  end
end
