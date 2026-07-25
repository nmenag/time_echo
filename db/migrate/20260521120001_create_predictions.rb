class CreatePredictions < ActiveRecord::Migration[8.1]
  def change
    create_table :predictions do |t|
      t.belongs_to :letter, null: false, foreign_key: true
      t.string :category, null: false
      t.text :prediction, null: false
      t.text :reality
      t.boolean :matched

      t.timestamps
    end
  end
end
