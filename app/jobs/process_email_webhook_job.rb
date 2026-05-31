class ProcessEmailWebhookJob < ApplicationJob
  queue_as :default

  def perform(payload)
    event_type = payload["type"]
    data = payload["data"] || {}

    tags = data["tags"] || {}
    letter_id = tags["letter_id"] || data.dig("headers", "X-Letter-ID")

    letter = Letter.find_by(id: letter_id) if letter_id.present?

    case event_type
    when "email.delivered"
      letter&.update(delivery_status: "delivered")
      Analytics::TrackEventService.call("email_delivered", { letter_id: letter_id, resend_id: data["email_id"] })
    when "email.opened"
      if letter
        letter.increment!(:open_count)
        letter.update(opened_at: Time.current)
      end
      Analytics::TrackEventService.call("email_opened", { letter_id: letter_id, resend_id: data["email_id"] })
    when "email.clicked"
      letter&.update(clicked_at: Time.current)
      Analytics::TrackEventService.call("link_clicked", { letter_id: letter_id, resend_id: data["email_id"] })
    when "email.bounced"
      letter&.update(delivery_status: "bounced")
      Analytics::TrackEventService.call("bounce_status", { letter_id: letter_id, resend_id: data["email_id"] })
    else
      Analytics::TrackEventService.call("webhook_received", { event_type: event_type, data: data })
    end
  end
end
