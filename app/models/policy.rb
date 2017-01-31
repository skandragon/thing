class Policy < ApplicationRecord
  CURRENT_VERSION = '20170201-000000'

  def has_current_policy?(user)
    @has_current_policy ||= Policy.where(version: CURRENT_VERSION, user_id: user.id).count > 0
  end
end
