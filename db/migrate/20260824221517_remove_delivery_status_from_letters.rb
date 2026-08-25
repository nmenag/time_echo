class RemoveDeliveryStatusFromLetters < ActiveRecord::Migration[8.1]
  def change
    remove_column :letters, :delivery_status, :string
  end
end
