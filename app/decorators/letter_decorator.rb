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
    left == 1 ? I18n.t("letters.one_day") : I18n.t("letters.x_days", count: left)
  end

  def status_badge
    if pending?
      "#{I18n.t('letters.capsule_in_transit_badge')} ⏳"
    else
      "#{I18n.t('letters.capsule_unlocked_badge')} ✨"
    end
  end

  def decorated_predictions
    PredictionDecorator.decorate(predictions)
  end
end
