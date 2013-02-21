class AddAvailableDaysToInstructorProfile < ActiveRecord::Migration
  def change
    add_column :instructor_profiles, :available_days, :date, array: true
  end
end
