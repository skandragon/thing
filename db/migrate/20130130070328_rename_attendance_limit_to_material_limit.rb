class RenameAttendanceLimitToMaterialLimit < ActiveRecord::Migration
  def change
    rename_column :instructables, :attendance_limit, :material_limit
  end
end
