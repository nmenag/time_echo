require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: 1) unless Gem.win_platform?

    setup { I18n.locale = :es }

    fixtures :all
  end
end
