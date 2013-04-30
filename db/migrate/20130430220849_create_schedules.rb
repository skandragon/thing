class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :user_id
      t.integer :instructables, array: true, default: '{}'
      t.string :watch_topics, array: true, default: '{}'
      t.string :watch_cultures, array: true, default: '{}'

      t.timestamps
    end
  end
end
