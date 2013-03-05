class AddOverrideLocationToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :override_location, :boolean
  end
end
