class DropSolidQueueTables < ActiveRecord::Migration[8.1]
  def change
    drop_table "solid_queue_blocked_executions", force: :cascade rescue nil
    drop_table "solid_queue_claimed_executions", force: :cascade rescue nil
    drop_table "solid_queue_failed_executions", force: :cascade rescue nil
    drop_table "solid_queue_ready_executions", force: :cascade rescue nil
    drop_table "solid_queue_recurring_executions", force: :cascade rescue nil
    drop_table "solid_queue_scheduled_executions", force: :cascade rescue nil

    drop_table "solid_queue_jobs", force: :cascade rescue nil
    drop_table "solid_queue_pauses", force: :cascade rescue nil
    drop_table "solid_queue_processes", force: :cascade rescue nil
    drop_table "solid_queue_recurring_tasks", force: :cascade rescue nil
    drop_table "solid_queue_semaphores", force: :cascade rescue nil
  end
end
