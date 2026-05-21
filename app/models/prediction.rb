class Prediction < ApplicationRecord
  belongs_to :letter

  CATEGORIES = %w[city salary relationship career achievement].freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :prediction, presence: true

  scope :by_category, ->(cat) { where(category: cat) }
  scope :matched, -> { where(matched: true) }
  scope :unmatched, -> { where(matched: false) }
end
