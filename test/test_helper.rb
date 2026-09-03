require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"

FileUtils.mkdir_p(File.expand_path("../app/assets/builds", __dir__))
FileUtils.touch(File.expand_path("../app/assets/builds/tailwind.css", __dir__))

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: 1) unless Gem.win_platform?

    setup { I18n.locale = :es }

    fixtures :all
  end
end
