# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_21_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "analytics_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_analytics_events_on_event_type"
    t.index ["occurred_at"], name: "index_analytics_events_on_occurred_at"
  end

  create_table "checkpoints", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "goals_progress"
    t.text "life_changes"
    t.datetime "scheduled_for", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_checkpoints_on_email"
  end

  create_table "collective_capsules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "unlock_date", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_collective_capsules_on_slug", unique: true
  end

  create_table "collective_contributions", force: :cascade do |t|
    t.integer "anxiety", null: false
    t.bigint "collective_capsule_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "energy", null: false
    t.integer "happiness", null: false
    t.integer "motivation", null: false
    t.text "prediction_text"
    t.datetime "updated_at", null: false
    t.index ["collective_capsule_id"], name: "index_collective_contributions_on_collective_capsule_id"
  end

  create_table "comments", force: :cascade do |t|
    t.boolean "approved", default: true, null: false
    t.string "author_name", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "letter_id", null: false
    t.datetime "updated_at", null: false
    t.index ["letter_id"], name: "index_comments_on_letter_id"
  end

  create_table "emotional_snapshots", force: :cascade do |t|
    t.integer "anxiety_level", null: false
    t.datetime "created_at", null: false
    t.integer "happiness_level", null: false
    t.bigint "letter_id", null: false
    t.integer "motivation_level", null: false
    t.datetime "updated_at", null: false
    t.index ["letter_id"], name: "index_emotional_snapshots_on_letter_id"
  end

  create_table "goals", force: :cascade do |t|
    t.boolean "achieved"
    t.datetime "created_at", null: false
    t.bigint "letter_id", null: false
    t.text "reflection"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["letter_id"], name: "index_goals_on_letter_id"
  end

  create_table "letters", force: :cascade do |t|
    t.datetime "clicked_at"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "deliver_at", null: false
    t.datetime "delivered_at"
    t.string "delivery_status", default: "pending", null: false
    t.string "email", null: false
    t.integer "open_count", default: 0, null: false
    t.datetime "opened_at"
    t.boolean "public", default: false, null: false
    t.boolean "recipient_delivery_permission", default: false, null: false
    t.string "recipient_email"
    t.string "recipient_name"
    t.string "relationship"
    t.integer "reveal_anxiety"
    t.integer "reveal_happiness"
    t.integer "reveal_motivation"
    t.string "status", default: "pending", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["deliver_at"], name: "index_letters_on_deliver_at"
    t.index ["email"], name: "index_letters_on_email"
    t.index ["public"], name: "index_letters_on_public"
    t.index ["status"], name: "index_letters_on_status"
  end

  create_table "predictions", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.bigint "letter_id", null: false
    t.boolean "matched"
    t.text "prediction", null: false
    t.text "reality"
    t.datetime "updated_at", null: false
    t.index ["letter_id"], name: "index_predictions_on_letter_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.bigint "letter_id", null: false
    t.string "reaction_type", null: false
    t.datetime "updated_at", null: false
    t.index ["letter_id"], name: "index_reactions_on_letter_id"
  end

  create_table "session_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["email"], name: "index_session_tokens_on_email"
    t.index ["token"], name: "index_session_tokens_on_token", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collective_contributions", "collective_capsules"
  add_foreign_key "comments", "letters"
  add_foreign_key "emotional_snapshots", "letters"
  add_foreign_key "goals", "letters"
  add_foreign_key "predictions", "letters"
  add_foreign_key "reactions", "letters"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
