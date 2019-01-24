# == Schema Information
#
# Table name: schedules
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  instructables :integer          default([]), is an Array
#  published     :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  year          :integer
#

class Schedule < ApplicationRecord
  belongs_to :user

  default_scope { where(year: 2019) }

  attr_accessor :token_access
end
