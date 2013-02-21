class CreateInstructorProfiles < ActiveRecord::Migration
  def change
    create_table :instructor_profiles do |t|
      t.integer :user_id
      t.boolean :approved
      t.string :sca_name
      t.string :sca_name_titled
      t.string :phone_number
      t.string :mundane_name
      t.integer :class_limit

      t.timestamps
    end
  end
end
