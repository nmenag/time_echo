class RemovePublicFromLetters < ActiveRecord::Migration[8.1]
  def change
    remove_column :letters, :public, :boolean
  end
end
