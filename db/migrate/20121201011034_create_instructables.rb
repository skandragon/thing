class CreateInstructables < ActiveRecord::Migration
  def change
    create_table :instructables do |t|
      t.integer :user_id
      t.boolean :approved
      t.integer :parent
      t.datetime :start_time
      t.datetime :end_time
      t.integer :location
      t.string :name
      t.string :subject
      t.integer :attendance_limit
      t.integer :handout_limit
      t.text :description
      t.integer :handout_fee
      t.integer :material_fee

      t.timestamps
    end
  end
end
