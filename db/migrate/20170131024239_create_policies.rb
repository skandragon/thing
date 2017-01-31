class CreatePolicies < ActiveRecord::Migration[5.0]
  def change
    create_table :policies do |t|
      t.string :area
      t.integer :user_id
      t.datetime :accepted_on
      t.integer :version

      t.timestamps
    end
    add_index :policies, [:user_id]
  end
end
