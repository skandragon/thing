class Policy < ApplicationRecord
  CURRENT_VERSION = '20220331-000001'

  def self.has_current_policy?(user)
    user && Policy.where(version: CURRENT_VERSION, user_id: user.id).count > 0
  end
end
