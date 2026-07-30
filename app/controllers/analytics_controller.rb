class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    metrics = Analytics::FetchMetricsService.call(current_user_email)

    @total_letters          = metrics.total_letters
    @delivered_letters      = metrics.delivered_letters
    @scheduled_letters      = metrics.scheduled_letters
    @open_rate              = metrics.open_rate
    @click_rate             = metrics.click_rate
    @bounce_rate            = metrics.bounce_rate
    @total_opens            = metrics.total_opens
    @total_predictions      = metrics.total_predictions
    @completed_predictions  = metrics.completed_predictions
    @matched_predictions    = metrics.matched_predictions
    @prediction_match_rate  = metrics.prediction_match_rate
    @avg_initial_happiness  = metrics.avg_initial_happiness
    @avg_initial_anxiety    = metrics.avg_initial_anxiety
    @avg_initial_motivation = metrics.avg_initial_motivation
    @avg_reveal_happiness   = metrics.avg_reveal_happiness
    @avg_reveal_anxiety     = metrics.avg_reveal_anxiety
    @avg_reveal_motivation  = metrics.avg_reveal_motivation
    @recent_events          = metrics.recent_events
  end
end
