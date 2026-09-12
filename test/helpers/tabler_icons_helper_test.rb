# frozen_string_literal: true

require "test_helper"

class TablerIconsHelperTest < ActionView::TestCase
  test "renders tabler icon with default size" do
    html = tabler_icon("clock")
    assert_includes html, "ti ti-clock"
    assert_includes html, "font-size: 16px"
    assert_includes html, "aria-hidden=\"true\""
  end

  test "renders tabler icon with custom size and class" do
    html = tabler_icon("lock-open", size: 22, class: "text-success")
    assert_includes html, "ti ti-lock-open text-success"
    assert_includes html, "font-size: 22px"
  end
end
