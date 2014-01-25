class AddYear < ActiveRecord::Migration
  def up
    add_column :instructables, :year, :integer
    add_column :instances, :year, :integer
    add_column :schedules, :year, :integer
    add_column :changelogs, :year, :integer

    execute('update instructables set year=2013')
    execute('update instances set year=2013')
    execute('update schedules set year=2013')
    execute('update changelogs set year=2013')
  end

  def down
    remove_column :instructables, :year
    remove_column :instances, :year
    remove_column :schedules, :year
    remove_column :changelogs, :year
  end
end
