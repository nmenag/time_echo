class AddRevealEmotionsToLetters < ActiveRecord::Migration[8.1]
  def change
    add_column :letters, :reveal_happiness, :integer
    add_column :letters, :reveal_anxiety, :integer
    add_column :letters, :reveal_motivation, :integer
  end
end
