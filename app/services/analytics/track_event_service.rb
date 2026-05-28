module Analytics
  class TrackEventService
    def self.call(event_type, metadata = {})
      new(event_type, metadata).call
    end

    def initialize(event_type, metadata = {})
      @event_type = event_type
      @metadata = metadata
    end

    def call
      AnalyticsEvent.create!(
        event_type: @event_type,
        metadata: @metadata,
        occurred_at: Time.current
      )
    end
  end
end
