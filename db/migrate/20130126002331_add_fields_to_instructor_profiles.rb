class AddFieldsToInstructorProfiles < ActiveRecord::Migration
  def change
    add_column :instructor_profiles, :kingdom, :string
    add_column :instructor_profiles, :phone_number_onsite, :string
    add_column :instructor_profiles, :contact_via, :text
    remove_column :instructor_profiles, :approved
  end
end
