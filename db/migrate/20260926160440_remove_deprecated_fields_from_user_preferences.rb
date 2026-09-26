# frozen_string_literal: true

class RemoveDeprecatedFieldsFromUserPreferences < ActiveRecord::Migration[8.1]
  def change
    change_table :user_preferences, bulk: true do |t|
      t.remove :theme, type: :string, default: "timeecho", null: false
      t.remove :appearance_mode, type: :string, default: "system", null: false
      t.remove :reflection_style, type: :string, default: "reflective", null: false
      t.remove :memory_frequency, type: :string, default: "normal", null: false
      t.remove :future_letter_reminders, type: :boolean, default: true, null: false
      t.remove :monthly_checkpoints, type: :boolean, default: true, null: false
      t.remove :surprise_memories, type: :boolean, default: true, null: false
      t.remove :emotional_summary_emails, type: :boolean, default: true, null: false
      t.remove :all_letters_private, type: :boolean, default: true, null: false
      t.remove :automatic_memories, type: :boolean, default: true, null: false
      t.remove :anonymous_analytics, type: :boolean, default: true, null: false
    end
  end
end
