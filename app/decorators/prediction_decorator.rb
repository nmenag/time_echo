class PredictionDecorator < ApplicationDecorator
  def category_label
    case category
    when "city"
      "🏠 #{I18n.t('predictions.category_city')}"
    when "career"
      "💼 #{I18n.t('predictions.category_career')}"
    when "salary"
      "💵 #{I18n.t('predictions.category_salary')}"
    when "relationship"
      "❤️ #{I18n.t('predictions.category_relationship')}"
    when "achievement"
      "🏆 #{I18n.t('predictions.category_achievement')}"
    when "happiness"
      "😊 #{I18n.t('predictions.category_happiness')}"
    else
      "🔮 #{category.titleize}"
    end
  end

  def result_badge
    if matched?
      if category == "salary" || category == "achievement"
        "#{I18n.t('predictions.superaste')} 🚀"
      else
        "#{I18n.t('predictions.you_did_it')} 🎉"
      end
    else
      if category == "city" || category == "relationship"
        "#{I18n.t('predictions.partially')} ➖"
      else
        "#{I18n.t('predictions.you_missed')} ❌"
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
