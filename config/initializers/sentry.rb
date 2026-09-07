# frozen_string_literal: true

sentry_dsn = Rails.application.credentials.dig(:sentry_dsn) || ENV["SENTRY_DSN"] || ENV["GLITCHTIP_DSN"]

if sentry_dsn.present?
  Sentry.init do |config|
    config.dsn = sentry_dsn
    config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
    config.send_default_pii = false
    config.environment = Rails.env
    config.enabled_environments = %w[production staging development]

    # Performance tracing rate (set to 0 if only error monitoring is desired)
    config.traces_sample_rate = 0.0
  end
end
