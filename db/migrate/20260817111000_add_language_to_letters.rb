class AddLanguageToLetters < ActiveRecord::Migration[8.1]
  def change
    add_column :letters, :language, :string, default: "en", null: false
  end
end
