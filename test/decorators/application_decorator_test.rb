require "test_helper"

class ApplicationDecoratorTest < ActiveSupport::TestCase
  test "decorate returns array of decorators for collection" do
    items = [ "a", "b", "c" ]
    result = ApplicationDecorator.decorate(items)
    assert_equal 3, result.size
    assert_kind_of ApplicationDecorator, result.first
  end

  test "decorate returns decorator for single object" do
    result = ApplicationDecorator.decorate("single")
    assert_kind_of ApplicationDecorator, result
  end
end
