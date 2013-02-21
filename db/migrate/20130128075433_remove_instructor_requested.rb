class RemoveInstructorRequested < ActiveRecord::Migration
  def change
    remove_column :users, :instructor_requested
  end
end
