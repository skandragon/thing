class RegenerateUserAccessTokens < ActiveRecord::Migration
  def up
    User.find_each do |user|
      user.regenerate_access_token
      user.save!
    end
  end

  def down
  end
end
