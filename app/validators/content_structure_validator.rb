# frozen_string_literal: true

class ContentStructureValidator < ActiveModel::EachValidator
  MAX_WORD_LENGTH = 45

  def validate_each(record, attribute, value)
    return if value.blank?

    str = value.to_s
    words = str.split(/\s+/).reject(&:blank?)

    if words.any? { |w| w.length > MAX_WORD_LENGTH }
      record.errors.add(attribute, :word_too_long, default: "cannot contain words longer than 45 characters")
      return
    end

    min_words = options[:min_words]
    if min_words && words.size < min_words
      record.errors.add(attribute, :too_few_words, default: "must contain at least #{min_words} words")
    end
  end
end
