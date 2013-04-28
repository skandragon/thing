class AddOriginalAndCommittedToChangelog < ActiveRecord::Migration
  def change
    add_column :changelogs, :original, :text
    add_column :changelogs, :committed, :text
  end
end
