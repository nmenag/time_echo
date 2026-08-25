require "json"
require "logger"

class JsonLogFormatter < Logger::Formatter
  SEVERITY_MAP = {
    "DEBUG" => "debug",
    "INFO" => "info",
    "WARN" => "warn",
    "ERROR" => "error",
    "FATAL" => "fatal"
  }.freeze

  def self.build(output)
    base = ActiveSupport::Logger.new(output)
    base.formatter = new
    tagged = ActiveSupport::TaggedLogging.new(base)

    tagged.formatter.define_singleton_method(:call) do |severity, timestamp, progname, msg|
      tags = current_tags
      payload = {
        ts: timestamp.getutc.iso8601(3),
        level: SEVERITY_MAP[severity] || severity,
        pid: Process.pid,
        thread: Thread.current.name || Thread.current.object_id,
        message: msg2str(msg)
      }
      payload[:tags] = tags if tags.any?
      "#{JSON.generate(payload)}\n"
    end

    tagged
  end
end
