class AddCheckScheduleCheckbox < ActiveRecord::Migration[5.0]
  def up
    add_column :instructables, :check_schedule_later, :boolean
    end
  def down
    remove_column :instructables, :check_schedule_later
  end
end
