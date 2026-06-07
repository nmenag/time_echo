class DropCommentsAndReactions < ActiveRecord::Migration[8.1]
  def change
    drop_table :comments do |t|
      t.boolean :approved, default: true, null: false
      t.string :author_name, null: false
      t.text :content, null: false
      t.bigint :letter_id, null: false
      t.timestamps
    end

    drop_table :reactions do |t|
      t.string :ip_address
      t.bigint :letter_id, null: false
      t.string :reaction_type, null: false
      t.timestamps
    end
  end
end
