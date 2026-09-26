# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :auditable, polymorphic: true, index: true
      t.string :actor_email, index: true
      t.string :action, null: false, index: true
      t.jsonb :metadata, default: {}, null: false
      t.string :ip_address
      t.string :user_agent

      t.datetime :created_at, null: false, index: true
    end

    add_index :audit_logs, %i[auditable_type auditable_id created_at], name: "index_audit_logs_on_auditable_and_created_at"
  end
end
