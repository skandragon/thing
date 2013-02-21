class AddRequestsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instructor_requested, :boolean
  end
end
