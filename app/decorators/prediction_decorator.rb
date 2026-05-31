class PredictionDecorator < ApplicationDecorator
  def category_label
    case category
    when "city"
      "🏠 Ubicación"
    when "career"
      "💼 Trabajo / Carrera"
    when "salary"
      "💵 Ingresos"
    when "relationship"
      "❤️ Relación sentimental"
    when "achievement"
      "🏆 Mayor logro"
    when "happiness"
      "😊 Felicidad"
    else
      "🔮 #{category.titleize}"
    end
  end

  def result_badge
    if matched?
      if category == "salary" || category == "achievement"
        "Superaste 🚀"
      else
        "Lo lograste! 🎉"
      end
    else
      if category == "city" || category == "relationship"
        "Parcialmente ➖"
      else
        "No acertaste ❌"
      end
    end
  end

  def result_badge_class
    if matched?
      "bg-emerald-500 text-white"
    else
      if category == "city" || category == "relationship"
        "bg-amber-500 text-white"
      else
        "bg-violet-900 text-white"
      end
    end
  end
end
