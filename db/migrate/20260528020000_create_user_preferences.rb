class CreateUserPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :user_preferences do |t|
      t.string :email, null: false

      t.boolean :future_letter_reminders, default: true, null: false
      t.boolean :monthly_checkpoints, default: true, null: false
      t.boolean :surprise_memories, default: true, null: false
      t.boolean :emotional_summary_emails, default: true, null: false

      t.string :appearance_mode, default: "system", null: false
      t.string :theme, default: "timeecho", null: false

      t.boolean :all_letters_private, default: true, null: false
      t.boolean :automatic_memories, default: true, null: false
      t.boolean :anonymous_analytics, default: true, null: false

      t.string :reflection_style, default: "reflective", null: false
      t.string :memory_frequency, default: "normal", null: false

      t.datetime :confirmed_at
      t.string :unconfirmed_email

      t.timestamps
    end

    add_index :user_preferences, :email, unique: true
  end
end
