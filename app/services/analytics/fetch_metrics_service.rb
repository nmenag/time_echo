require "ostruct"

module Analytics
  class FetchMetricsService
    def self.call(email)
      new(email).call
    end

    def initialize(email)
      @email = email
    end

    def call
      letters = UserTimelineQuery.call(@email)
      letter_ids = letters.pluck(:id)

      letter_stats = letters.select(
        "COUNT(*) as total",
        "COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered",
        "COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending",
        "COUNT(CASE WHEN status = 'delivered' AND opened_at IS NOT NULL THEN 1 END) as opened",
        "COUNT(CASE WHEN status = 'delivered' AND clicked_at IS NOT NULL THEN 1 END) as clicked",
        "COUNT(CASE WHEN delivery_status = 'bounced' THEN 1 END) as bounced",
        "SUM(COALESCE(open_count, 0)) as total_opens"
      ).take

      total_letters = letter_stats&.total.to_i
      delivered_letters = letter_stats&.delivered.to_i
      scheduled_letters = letter_stats&.pending.to_i
      delivered_and_opened = letter_stats&.opened.to_i
      delivered_and_clicked = letter_stats&.clicked.to_i
      bounced_letters = letter_stats&.bounced.to_i
      total_opens = letter_stats&.total_opens.to_i

      open_rate = delivered_letters > 0 ? (delivered_and_opened.to_f / delivered_letters * 100).round(1) : 0
      click_rate = delivered_letters > 0 ? (delivered_and_clicked.to_f / delivered_letters * 100).round(1) : 0
      bounce_rate = total_letters > 0 ? (bounced_letters.to_f / total_letters * 100).round(1) : 0

      if letter_ids.any?
        pred_stats = Prediction.where(letter_id: letter_ids).select(
          "COUNT(*) as total",
          "COUNT(CASE WHEN reality IS NOT NULL THEN 1 END) as completed",
          "COUNT(CASE WHEN matched = true THEN 1 END) as matched"
        ).take

        total_predictions = pred_stats&.total.to_i
        completed_predictions = pred_stats&.completed.to_i
        matched_predictions = pred_stats&.matched.to_i
      else
        total_predictions = 0
        completed_predictions = 0
        matched_predictions = 0
      end
      prediction_match_rate = completed_predictions > 0 ? (matched_predictions.to_f / completed_predictions * 100).round(1) : 0

      if letter_ids.any?
        initial_snapshots = EmotionalSnapshot.where(letter_id: letter_ids).select(
          "AVG(happiness_level) as happiness",
          "AVG(anxiety_level) as anxiety",
          "AVG(motivation_level) as motivation"
        ).take

        avg_initial_happiness = initial_snapshots&.happiness&.to_f&.round(1) || 0
        avg_initial_anxiety = initial_snapshots&.anxiety&.to_f&.round(1) || 0
        avg_initial_motivation = initial_snapshots&.motivation&.to_f&.round(1) || 0
      else
        avg_initial_happiness = 0
        avg_initial_anxiety = 0
        avg_initial_motivation = 0
      end

      revealed_letters = letters.where.not(reveal_happiness: nil).select(
        "AVG(reveal_happiness) as happiness",
        "AVG(reveal_anxiety) as anxiety",
        "AVG(reveal_motivation) as motivation"
      ).take

      avg_reveal_happiness = revealed_letters&.happiness&.to_f&.round(1) || 0
      avg_reveal_anxiety = revealed_letters&.anxiety&.to_f&.round(1) || 0
      avg_reveal_motivation = revealed_letters&.motivation&.to_f&.round(1) || 0

      if letter_ids.any?
        recent_events = AnalyticsEvent.where("metadata->>'email' = ?", @email)
                                        .or(AnalyticsEvent.where("metadata->>'letter_id' IN (?)", letter_ids.map(&:to_s)))
                                        .order(occurred_at: :desc)
                                        .limit(10)
      else
        recent_events = AnalyticsEvent.where("metadata->>'email' = ?", @email)
                                        .order(occurred_at: :desc)
                                        .limit(10)
      end

      OpenStruct.new(
        total_letters: total_letters,
        delivered_letters: delivered_letters,
        scheduled_letters: scheduled_letters,
        open_rate: open_rate,
        click_rate: click_rate,
        bounce_rate: bounce_rate,
        total_opens: total_opens,
        total_predictions: total_predictions,
        completed_predictions: completed_predictions,
        matched_predictions: matched_predictions,
        prediction_match_rate: prediction_match_rate,
        avg_initial_happiness: avg_initial_happiness,
        avg_initial_anxiety: avg_initial_anxiety,
        avg_initial_motivation: avg_initial_motivation,
        avg_reveal_happiness: avg_reveal_happiness,
        avg_reveal_anxiety: avg_reveal_anxiety,
        avg_reveal_motivation: avg_reveal_motivation,
        recent_events: recent_events
      )
    end
  end
end
