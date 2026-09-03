class LetterDecorator < ApplicationDecorator
  def display_title
    if title == "your_letter" || title == I18n.t("landing.your_letter", locale: :en) || title == I18n.t("landing.your_letter", locale: :es)
      I18n.t("landing.your_letter")
    else
      title
    end
  end

  def local_scheduled_at
    return nil unless scheduled_at
    tz = Time.find_zone(timezone) || Time.find_zone("UTC")
    scheduled_at.in_time_zone(tz)
  end

  def formatted_created_at
    tz = Time.find_zone(timezone) || Time.find_zone("UTC")
    I18n.l(created_at.in_time_zone(tz).to_date, format: :long)
  end

  def formatted_delivered_at
    return nil unless delivered_at
    tz = Time.find_zone(timezone) || Time.find_zone("UTC")
    I18n.l(delivered_at.in_time_zone(tz).to_date, format: :long)
  end

  def formatted_deliver_at
    return nil unless local_scheduled_at
    I18n.l(local_scheduled_at.to_date, format: :long)
  end
  alias_method :formatted_scheduled_at, :formatted_deliver_at

  def days_left
    return 0 unless local_scheduled_at
    tz = Time.find_zone(timezone) || Time.find_zone("UTC")
    current_local_date = Time.current.in_time_zone(tz).to_date
    (local_scheduled_at.to_date - current_local_date).to_i
  end

  def days_left_text
    left = days_left
    left == 1 ? I18n.t("letters.one_day") : I18n.t("letters.x_days", count: left)
  end

  def status_badge
    if pending? || queued?
      "#{I18n.t('letters.capsule_in_transit_badge')} ⏳"
    else
      "#{I18n.t('letters.capsule_unlocked_badge')} ✨"
    end
  end

  def decorated_predictions
    PredictionDecorator.decorate(predictions)
  end
end
