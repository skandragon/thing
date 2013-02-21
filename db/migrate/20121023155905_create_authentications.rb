class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.string :oauth
      t.datetime :oauth_expires_at

      t.timestamps
    end
    add_index :authentications, :user_id
  end
end
