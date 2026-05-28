class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def resend
    payload = JSON.parse(request.raw_post)

    # Process the webhook payload asynchronously using Solid Queue
    ProcessEmailWebhookJob.perform_later(payload)

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse Resend webhook JSON: #{e.message}")
    head :bad_request
  end
end
