class CreateChangelog < ActiveRecord::Migration
  def change
    create_table :changelogs do |t|
      t.integer :user_id
      t.string :action
      t.integer :model_id
      t.string :model_name
      t.text :changelog
      t.boolean :notified, default: false

      t.timestamps
    end
  end
end
