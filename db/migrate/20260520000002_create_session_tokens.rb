class CreateSessionTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :session_tokens do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :session_tokens, :token, unique: true
    add_index :session_tokens, :email
  end
end
