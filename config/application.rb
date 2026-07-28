require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TimeEcho
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.active_record.encryption.primary_key = Rails.application.credentials.active_record_encryption[:primary_key]
    config.active_record.encryption.deterministic_key = Rails.application.credentials.active_record_encryption[:deterministic_key]
    config.active_record.encryption.key_derivation_salt = Rails.application.credentials.active_record_encryption[:key_derivation_salt]
    config.load_defaults 8.1
    config.active_job.queue_adapter = :good_job
    config.good_job.enable_cron = true
    config.good_job.cron = {
      deliver_pending_letters: {
        cron: "* * * * *",
        class: "DeliverPendingLettersJob"
      },
      cleanup_expired_tokens: {
        cron: "0 * * * *",
        class: "CleanupExpiredTokensJob"
      }
    }

    # Configure available locales and default locale
    config.i18n.available_locales = [ :es ]
    config.i18n.default_locale = :es

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
