class AddNoContactToInstructorProfile < ActiveRecord::Migration
  def change
    add_column :instructor_profiles, :no_contact, :boolean
  end
end
