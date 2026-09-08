# frozen_string_literal: true

namespace :error_tracking do
  desc "Send a test event to GlitchTip / Sentry to verify connectivity"
  task test: :environment do
    if Sentry.configuration&.dsn.present?
      puts "Sending test event to GlitchTip/Sentry..."
      event_id = Sentry.capture_message("TimeEcho Error Tracking Test: Everything is connected and working perfectly!", level: :info)
      if event_id
        puts "Success! Event dispatched with ID: #{event_id}"
        puts "Check your GlitchTip dashboard at http://localhost:8000 to see the event."
      else
        puts "Event was captured, but no ID returned. Verify your DSN is valid."
      end
    else
      puts "Error: Sentry / GlitchTip is not configured. Please set sentry_dsn in credentials or SENTRY_DSN in ENV."
    end
  end
end
