class AddPuPositionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pu_staff, :boolean
  end
end
