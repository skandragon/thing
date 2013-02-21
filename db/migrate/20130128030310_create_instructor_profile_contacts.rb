class CreateInstructorProfileContacts < ActiveRecord::Migration
  def change
    create_table :instructor_profile_contacts do |t|
      t.integer :instructor_profile_id
      t.string :protocol
      t.string :address

      t.timestamps
    end
  end
end
