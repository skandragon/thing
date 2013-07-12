# == Schema Information
#
# Table name: schedules
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  instructables :integer          default([])
#  published     :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Schedule < ActiveRecord::Base
  PENNSIC_YEAR = 42

  belongs_to :user
end
