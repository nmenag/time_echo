class CreateLetters < ActiveRecord::Migration[8.1]
  def change
    create_table :letters do |t|
      t.string :email, null: false
      t.text :content, null: false
      t.datetime :deliver_at, null: false
      t.datetime :delivered_at
      t.datetime :opened_at
      t.datetime :clicked_at
      t.string :status, null: false, default: "pending"
      t.boolean :public, null: false, default: false
      t.integer :open_count, null: false, default: 0
      t.string :delivery_status, null: false, default: "pending"

      t.timestamps
    end

    add_index :letters, :email
    add_index :letters, :status
    add_index :letters, :deliver_at
    add_index :letters, :public
  end
end
