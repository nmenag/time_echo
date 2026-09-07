# frozen_string_literal: true

require "test_helper"
require "rake"

class ErrorTrackingTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("error_tracking:test")
  end

  test "error_tracking:test task executes successfully" do
    Rake::Task["error_tracking:test"].reenable
    assert_output(/TimeEcho Error Tracking Test|Sentry \/ GlitchTip is not configured/) do
      Rake::Task["error_tracking:test"].invoke
    end
  end
end
