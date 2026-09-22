class CreateVerifiedEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :verified_emails do |t|
      t.string :email, null: false
      t.string :token
      t.datetime :token_expires_at
      t.datetime :verified_at

      t.timestamps
    end

    add_index :verified_emails, :email
    add_index :verified_emails, "lower((email)::text)", unique: true, name: "index_verified_emails_on_lower_email"
    add_index :verified_emails, :token, unique: true
  end
end
