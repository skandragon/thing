class AddScheduleToInstructable < ActiveRecord::Migration
  def change
    add_column :instructables, :schedule, :string
  end
end
