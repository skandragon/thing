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
  PENNSIC_YEAR = 43

  belongs_to :user

  default_scope :conditions => { year: 2014 }

  attr_accessor :token_access
end
