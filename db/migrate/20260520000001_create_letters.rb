class CreateLetters < ActiveRecord::Migration[8.1]
  def change
    create_table :letters do |t|
      t.string :email, null: false
      t.string :title
      t.text :content, null: false
      t.datetime :deliver_at, null: false
      t.datetime :delivered_at
      t.datetime :opened_at
      t.string :status, null: false, default: "pending"
      t.integer :reveal_happiness
      t.integer :reveal_anxiety
      t.integer :reveal_motivation
      t.string :language, default: "en", null: false

      t.timestamps
    end

    add_index :letters, :email
    add_index :letters, :status
    add_index :letters, :deliver_at
  end
end
