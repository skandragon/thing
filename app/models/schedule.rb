class Schedule < ActiveRecord::Base
  attr_accessible :instructables, :user_id, :watch_cultures, :watch_topics
end
