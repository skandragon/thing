class MakeRequestedTimesAnArray < ActiveRecord::Migration
  def up
    add_column :instructables, :requested_times, :string, array: true
    Instructable.reset_column_information

    Instructable.all.each do |i|
      i.requested_times = [ i.requested_time ]
      i.save!
    end

    remove_column :instructables, :requested_time
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
