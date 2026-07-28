class AddMvpFeatures < ActiveRecord::Migration[8.1]
  def change
    # Add title column to letters if it doesn't exist
    unless column_exists?(:letters, :title)
      add_column :letters, :title, :string
    end

    # Drop tables if they exist to start fresh with requested schema
    drop_table :predictions, if_exists: true
    drop_table :emotional_snapshots, if_exists: true

    # Create predictions table
    create_table :predictions do |t|
      t.belongs_to :letter, null: false, foreign_key: true
      t.string :category, null: false
      t.text :prediction, null: false
      t.text :reality
      t.boolean :matched

      t.timestamps
    end

    # Create emotional_snapshots table
    create_table :emotional_snapshots do |t|
      t.belongs_to :letter, null: false, foreign_key: true
      t.integer :happiness_level, null: false
      t.integer :anxiety_level, null: false
      t.integer :motivation_level, null: false

      t.timestamps
    end
  end
end
