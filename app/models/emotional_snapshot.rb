class EmotionalSnapshot < ApplicationRecord
  belongs_to :letter

  validates :happiness_level, presence: true, numericality: { only_integer: true, in: 1..10 }
  validates :anxiety_level, presence: true, numericality: { only_integer: true, in: 1..10 }
  validates :motivation_level, presence: true, numericality: { only_integer: true, in: 1..10 }
end
