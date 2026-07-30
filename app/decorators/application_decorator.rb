require "delegate"

class ApplicationDecorator < SimpleDelegator
  def initialize(object)
    super(object)
    @object = object
  end

  def self.decorate(object_or_collection)
    if object_or_collection.respond_to?(:map)
      object_or_collection.map { |obj| new(obj) }
    else
      new(object_or_collection)
    end
  end

  private

  attr_reader :object
end
