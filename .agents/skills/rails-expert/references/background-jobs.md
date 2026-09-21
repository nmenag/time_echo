# Background Jobs with Active Job & Sidekiq 7+

## Sidekiq 7+ Setup

```ruby
# Gemfile
gem 'sidekiq'
gem 'sidekiq-cron' # Optional: scheduled jobs

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end

# config/sidekiq.yml
:concurrency: 5
:queues:
  - critical
  - default
  - low
```

## Modern Active Job Design

Active Job is Rails' built-in framework that abstracts queue backends (Sidekiq, GoodJob, Solid Queue). Always use native Active Job methods (`retry_on`, `discard_on`) when inheriting from `ApplicationJob`:

```ruby
# app/jobs/email_sender_job.rb
class EmailSenderJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, wait: :exponentially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(user_id, email_type)
    user = User.find(user_id)
    UserMailer.send_notification(user, email_type).deliver_now
  end
end

# Usage — always pass JSON-serializable primitives (Strings, Integers), never Symbols
EmailSenderJob.perform_later(user.id, "welcome")

# Perform at specific time
EmailSenderJob.set(wait: 1.hour).perform_later(user.id, "reminder")
EmailSenderJob.set(wait_until: Date.tomorrow.noon).perform_later(user.id, "digest")
```

## Pure Sidekiq 7+ Job (`Sidekiq::Job`)

When bypassing Active Job for raw Sidekiq speed or direct Redis features, use `Sidekiq::Job` (`Sidekiq::Worker` is deprecated in Sidekiq 7):

```ruby
# app/sidekiq/import_data_job.rb
class ImportDataJob
  include Sidekiq::Job # Note: replaces deprecated include Sidekiq::Worker

  sidekiq_options queue: :low, retry: 5

  # Custom retry backoff for Sidekiq
  sidekiq_retry_in do |count, exception|
    case exception
    when NetworkError
      10 * (count + 1)
    when RateLimitError
      1.hour
    else
      :default
    end
  end

  # Called when all retries are exhausted
  sidekiq_retries_exhausted do |msg, exception|
    Rails.logger.error("Job #{msg['class']} with args #{msg['args']} failed: #{exception.message}")
  end

  def perform(data_url)
    DataImporter.run(data_url)
  end
end

# Enqueue pure Sidekiq job
ImportDataJob.perform_async("https://example.com/data.csv")
```

## Queue Priority

```ruby
class CriticalJob < ApplicationJob
  queue_as :critical

  def perform
    # High priority work
  end
end

class ReportGenerationJob < ApplicationJob
  queue_as :low

  def perform
    # Can wait
  end
end
```

## Batch Processing

```ruby
class BulkEmailJob < ApplicationJob
  def perform(user_ids)
    # Process in batches to avoid memory ballooning
    user_ids.in_groups_of(100, false) do |batch|
      batch.each do |user_id|
        user = User.find_by(id: user_id)
        next unless user

        UserMailer.newsletter(user).deliver_now
      end
    end
  end
end
```

## Scheduled Jobs

```ruby
# Using sidekiq-cron
# config/initializers/sidekiq.rb
schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  # Psych 4+ (Ruby 3.1+) requires aliases: true for YAML anchors
  schedule = YAML.load_file(schedule_file, aliases: true)
  Sidekiq::Cron::Job.load_from_hash(schedule) if schedule
end

# config/schedule.yml
daily_report:
  cron: "0 6 * * *"
  class: "DailyReportJob"
  queue: default

cleanup_old_records:
  cron: "0 2 * * 0" # Sunday at 2am
  class: "CleanupJob"
  queue: low
```

## Idempotent Job Pattern

```ruby
class ProcessOrderJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  def perform(order_id)
    order = Order.find(order_id)
    return if order.processed?

    order.process!
  end
end
```

## Testing Jobs (RSpec)

```ruby
# spec/jobs/email_sender_job_spec.rb
require 'rails_helper'

RSpec.describe EmailSenderJob, type: :job do
  let(:user) { create(:user) }

  describe "#perform" do
    it "sends welcome email" do
      expect {
        described_class.perform_now(user.id, "welcome")
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "enqueues job" do
      expect {
        described_class.perform_later(user.id, "welcome")
      }.to have_enqueued_job(described_class)
        .with(user.id, "welcome")
        .on_queue("default")
    end
  end
end
```

## Monitoring & CLI

```ruby
# Check queue sizes via Sidekiq API
Sidekiq::Queue.new("default").size
Sidekiq::ScheduledSet.new.size
Sidekiq::RetrySet.new.size
Sidekiq::DeadSet.new.size
```

## Best Practices

- Use `ApplicationJob` with native `retry_on` / `discard_on` for portability
- In raw Sidekiq, use `include Sidekiq::Job` (`Sidekiq::Worker` is deprecated)
- Always pass JSON-safe primitives (Strings, Integers, Booleans) — avoid Ruby symbols to satisfy Sidekiq 7 strict argument validation
- Pass record IDs, never ActiveRecord object instances
- Keep jobs small, atomic, and idempotent
- Set appropriate queue priorities and concurrency
- Monitor queue latency and error rates
