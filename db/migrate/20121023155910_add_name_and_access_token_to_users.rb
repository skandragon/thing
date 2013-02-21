class AddNameAndAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :access_token, :string
    add_column :users, :admin, :boolean
  end
end
