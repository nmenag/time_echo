require_relative "../../lib/json_log_formatter"

if Rails.env.production? || Rails.env.staging?
  Rails.logger = JsonLogFormatter.build(STDOUT)
end
