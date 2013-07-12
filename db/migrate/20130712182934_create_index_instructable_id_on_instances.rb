class CreateIndexInstructableIdOnInstances < ActiveRecord::Migration
  def change
    add_index :instances, [:instructable_id]
  end
end
