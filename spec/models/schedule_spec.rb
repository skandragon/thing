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

require 'spec_helper'

describe Schedule do
  pending "add some examples to (or delete) #{__FILE__}"
end
