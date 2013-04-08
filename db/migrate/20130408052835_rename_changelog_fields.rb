class RenameChangelogFields < ActiveRecord::Migration
  def change
    rename_column :changelogs, :model_id, :target_id
    rename_column :changelogs, :model_name, :target_type
  end
end
