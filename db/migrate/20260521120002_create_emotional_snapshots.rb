class CreateEmotionalSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :emotional_snapshots do |t|
      t.belongs_to :letter, null: false, foreign_key: true
      t.integer :happiness_level, null: false
      t.integer :anxiety_level, null: false
      t.integer :motivation_level, null: false

      t.timestamps
    end
  end
end
