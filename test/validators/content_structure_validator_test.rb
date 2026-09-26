# frozen_string_literal: true

require "test_helper"

class ContentStructureValidatorTest < ActiveSupport::TestCase
  class DummyRecord
    include ActiveModel::Model
    attr_accessor :content

    validates :content, content_structure: { min_words: 10 }
  end

  test "accepts valid content with proper paragraph structure and normal words" do
    valid_text = <<~TEXT
      Dear Future Self,

      I am writing this digital time capsule to reflect upon my current life goals, personal aspirations, and expectations.

      May the future bring wisdom, serenity, and fulfillment in all your endeavors.
    TEXT

    record = DummyRecord.new(content: valid_text)
    assert record.valid?, "Expected record to be valid with paragraph structure"
  end

  test "rejects content containing words longer than 45 characters" do
    long_word = "a" * 46
    text = "Hello future self here is a word #{long_word} that is way too long to be a real word in any sentence."

    record = DummyRecord.new(content: text)
    assert_not record.valid?
    assert_includes record.errors[:content], I18n.t("errors.messages.word_too_long")
  end

  test "rejects content with fewer than 10 words" do
    short_text = "Hello future self text"

    record = DummyRecord.new(content: short_text)
    assert_not record.valid?
    assert_includes record.errors[:content], I18n.t("errors.messages.too_few_words")
  end

  test "accepts content with a single paragraph" do
    single_paragraph = "This is a single paragraph digital time capsule reflection containing enough words to express meaningful thoughts and aspirations for the future self without requiring artificial paragraph breaks."

    record = DummyRecord.new(content: single_paragraph)
    assert record.valid?, "Expected single paragraph content to be valid"
  end
end
