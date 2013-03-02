class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.references :instructable
      t.datetime :start_time
      t.datetime :end_time
      t.string :location

      t.timestamps
    end

    remove_column :instructables, :start_time
    remove_column :instructables, :end_time
    remove_column :instructables, :location
  end
end
