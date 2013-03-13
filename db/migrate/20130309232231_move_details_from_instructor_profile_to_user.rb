class MoveDetailsFromInstructorProfileToUser < ActiveRecord::Migration
  def change
    # Add fields we care about from InstructorProfile to User table
    add_column :users, :sca_name, :string
    add_column :users, :sca_title, :string
    add_column :users, :phone_number, :string
    add_column :users, :class_limit, :integer
    add_column :users, :kingdom, :string
    add_column :users, :phone_number_onsite, :string
    add_column :users, :contact_via, :text
    add_column :users, :no_contact, :boolean, default: false
    add_column :users, :available_days, :date, array: true

    # Remap so User and InstructorProfile use same field name; the user was
    # probably more careful with filling in the Instructor Profile so this
    # will use that to overwrite the value in the User attribute
    rename_column :users, :name, :mundane_name

    # Need to track instructor state w/o using InstructorProfile
    add_column :users, :instructor, :boolean, default: false

    InstructorProfile.find_each do |profile|
      user = profile.user
      columns = InstructorProfile.column_names - ['id', 'user_id', 'created_at', 'updated_at']
      columns.each { |attr|
        new_value = profile.send(attr)
        user.send("#{attr}=", new_value) unless new_value.blank?
      }
      user.instructor = true
      user.save!
    end

    # Update InstructorProfileContacts to now point to User
    add_column :instructor_profile_contacts, :user_id, :integer

    InstructorProfileContact.find_each do |contact|
      profile = contact.instructor_profile
      if profile.present?
        contact.user_id = profile.user_id
        contact.save!
      else
        contact.destroy
      end
    end

    remove_column :instructor_profile_contacts, :instructor_profile_id

    drop_table :instructor_profiles
  end
end
