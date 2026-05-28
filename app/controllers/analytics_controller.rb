class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    @letters = UserTimelineQuery.call(current_user_email)
    @total_letters = @letters.count
    @delivered_letters = @letters.delivered.count
    @scheduled_letters = @letters.pending.count

    # Open rate: percentage of delivered letters that have been opened
    delivered_and_opened = @letters.delivered.where.not(opened_at: nil).count
    @open_rate = @delivered_letters > 0 ? (delivered_and_opened.to_f / @delivered_letters * 100).round(1) : 0

    # Click rate: percentage of delivered letters that have been clicked
    delivered_and_clicked = @letters.delivered.where.not(clicked_at: nil).count
    @click_rate = @delivered_letters > 0 ? (delivered_and_clicked.to_f / @delivered_letters * 100).round(1) : 0

    # Bounces
    @bounced_letters = @letters.where(delivery_status: "bounced").count
    @bounce_rate = @total_letters > 0 ? (@bounced_letters.to_f / @total_letters * 100).round(1) : 0

    # Total open count
    @total_opens = @letters.sum(:open_count)

    # Predictions Analytics
    @total_predictions = Prediction.where(letter_id: @letters.pluck(:id)).count
    @completed_predictions = Prediction.where(letter_id: @letters.pluck(:id)).where.not(reality: nil).count
    @matched_predictions = Prediction.where(letter_id: @letters.pluck(:id), matched: true).count
    @prediction_match_rate = @completed_predictions > 0 ? (@matched_predictions.to_f / @completed_predictions * 100).round(1) : 0

    # Emotional Snapshots Analytics
    initial_snapshots = EmotionalSnapshot.where(letter_id: @letters.pluck(:id))
    @avg_initial_happiness = initial_snapshots.average(:happiness_level)&.to_f&.round(1) || 0
    @avg_initial_anxiety = initial_snapshots.average(:anxiety_level)&.to_f&.round(1) || 0
    @avg_initial_motivation = initial_snapshots.average(:motivation_level)&.to_f&.round(1) || 0

    # Revealed emotions
    revealed_letters = @letters.where.not(reveal_happiness: nil)
    @avg_reveal_happiness = revealed_letters.average(:reveal_happiness)&.to_f&.round(1) || 0
    @avg_reveal_anxiety = revealed_letters.average(:reveal_anxiety)&.to_f&.round(1) || 0
    @avg_reveal_motivation = revealed_letters.average(:reveal_motivation)&.to_f&.round(1) || 0

    # Fetch recent events for this user's email or letters
    letter_ids = @letters.pluck(:id)
    if letter_ids.any?
      @recent_events = AnalyticsEvent.where("metadata->>'email' = ?", current_user_email)
                                      .or(AnalyticsEvent.where("metadata->>'letter_id' IN (?)", letter_ids.map(&:to_s)))
                                      .order(occurred_at: :desc)
                                      .limit(10)
    else
      @recent_events = AnalyticsEvent.where("metadata->>'email' = ?", current_user_email)
                                      .order(occurred_at: :desc)
                                      .limit(10)
    end
  end
end
