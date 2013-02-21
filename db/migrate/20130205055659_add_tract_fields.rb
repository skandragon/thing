class AddTractFields < ActiveRecord::Migration
  def change
    add_column :instructables, :tract, :string
    add_column :users, :coordinator_tract, :string
    remove_column :users, :coordinator
  end
end
