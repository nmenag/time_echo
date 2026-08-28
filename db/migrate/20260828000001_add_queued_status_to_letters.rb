class AddQueuedStatusToLetters < ActiveRecord::Migration[8.1]
  def change
    add_column :letters, :queued_at, :datetime
  end
end
