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

      letter_stats = letters.unscope(:order).select(
        "COUNT(*) as total",
        "COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered",
        "COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending",
        "AVG(CASE WHEN reveal_happiness IS NOT NULL THEN reveal_happiness END) as avg_reveal_happiness",
        "AVG(CASE WHEN reveal_anxiety IS NOT NULL THEN reveal_anxiety END) as avg_reveal_anxiety",
        "AVG(CASE WHEN reveal_motivation IS NOT NULL THEN reveal_motivation END) as avg_reveal_motivation"
      ).take

      total_letters = letter_stats&.total.to_i
      delivered_letters = letter_stats&.delivered.to_i
      scheduled_letters = letter_stats&.pending.to_i

      avg_reveal_happiness = letter_stats&.avg_reveal_happiness&.to_f&.round(1) || 0
      avg_reveal_anxiety = letter_stats&.avg_reveal_anxiety&.to_f&.round(1) || 0
      avg_reveal_motivation = letter_stats&.avg_reveal_motivation&.to_f&.round(1) || 0

      if letter_ids.any?
        pred_stats = Prediction.where(letter_id: letter_ids).select(
          "COUNT(*) as total",
          "COUNT(CASE WHEN reality IS NOT NULL THEN 1 END) as completed",
          "COUNT(CASE WHEN matched = true THEN 1 END) as matched_count"
        ).take

        total_predictions = pred_stats&.total.to_i
        completed_predictions = pred_stats&.completed.to_i
        matched_predictions = pred_stats&.matched_count.to_i
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
