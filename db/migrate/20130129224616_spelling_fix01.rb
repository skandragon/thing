class SpellingFix01 < ActiveRecord::Migration
  def change
    rename_column :instructables, :head_source_description, :heat_source_description
  end
end
