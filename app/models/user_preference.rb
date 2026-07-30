class UserPreference < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  validates :appearance_mode, inclusion: { in: %w[light dark system] }
  validates :theme, inclusion: { in: %w[timeecho cupcake pastel autumn luxury] }
  validates :reflection_style, inclusion: { in: %w[reflective motivational nostalgic] }
  validates :memory_frequency, inclusion: { in: %w[low normal frequent] }
end
