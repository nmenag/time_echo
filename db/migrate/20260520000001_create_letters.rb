class CreateLetters < ActiveRecord::Migration[8.1]
  def change
    create_table :letters do |t|
      t.string :email, null: false
      t.string :title
      t.text :content, null: false
      t.datetime :deliver_at, null: false
      t.datetime :delivered_at
      t.datetime :opened_at
      t.datetime :clicked_at
      t.string :status, null: false, default: "pending"
      t.integer :open_count, null: false, default: 0
      t.string :delivery_status, null: false, default: "pending"
      t.integer :reveal_happiness
      t.integer :reveal_anxiety
      t.integer :reveal_motivation

      t.timestamps
    end

    add_index :letters, :email
    add_index :letters, :status
    add_index :letters, :deliver_at
    add_index :letters, :public
  end
end
