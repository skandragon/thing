class AddInstructorAndCoordinatorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instructor, :boolean
    add_column :users, :coordinator, :boolean
  end
end
