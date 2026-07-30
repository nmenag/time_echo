class LetterDecorator < ApplicationDecorator
  def formatted_created_at
    I18n.l(created_at.to_date, format: :long)
  end

  def formatted_delivered_at
    return nil unless delivered_at
    I18n.l(delivered_at.to_date, format: :long)
  end

  def formatted_deliver_at
    return nil unless deliver_at
    I18n.l(deliver_at.to_date, format: :long)
  end

  def days_left
    (deliver_at.to_date - Date.current).to_i
  end

  def days_left_text
    left = days_left
    left == 1 ? "1 día" : "#{left} días"
  end

  def status_badge
    if pending?
      "Cápsula en tránsito ⏳"
    else
      "Cápsula desbloqueada ✨"
    end
  end

  def decorated_predictions
    PredictionDecorator.decorate(predictions)
  end
end
