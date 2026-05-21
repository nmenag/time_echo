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
