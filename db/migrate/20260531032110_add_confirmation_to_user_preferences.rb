class AddConfirmationToUserPreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :user_preferences, :confirmed_at, :datetime
    add_column :user_preferences, :unconfirmed_email, :string
  end
end
