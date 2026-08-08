ENV["RAILS_ENV"] ||= "test"
require "simplecov"
SimpleCov.start
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    workers = if ENV["CI"] || ENV["WSL_DISTRO_NAME"] || Gem.win_platform?
      1
    else
      :number_of_processors
    end
    parallelize(workers: workers)

    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
