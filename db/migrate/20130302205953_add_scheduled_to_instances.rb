class AddScheduledToInstances < ActiveRecord::Migration
  def change
    add_column :instructables, :scheduled, :boolean, default: false
  end
end
