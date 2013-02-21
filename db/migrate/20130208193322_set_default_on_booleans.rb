class SetDefaultOnBooleans < ActiveRecord::Migration
  def change
    Instructable.all do |i|
      i.approved ||= false
      i.adult_only ||= false
      i.location_camp ||= false
      i.heat_source ||= false
      i.save!(validate: false)
    end
    change_column :instructables, :approved, :boolean, default: false
    change_column :instructables, :location_camp, :boolean, default: false
    change_column :instructables, :heat_source, :boolean, default: false
    change_column :instructables, :adult_only, :boolean, default: false

    InstructorProfile.all do |i|
      i.no_contact ||= false
      i.save!(validate: false)
    end
    change_column :instructor_profiles, :no_contact, :boolean, default: false

    User.all do |u|
      u.admin ||= false
      u.save!(validate: false)
    end
    change_column :users, :admin, :boolean, default: false
  end
end
