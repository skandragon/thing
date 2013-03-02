# == Schema Information
#
# Table name: instances
#
#  id              :integer          not null, primary key
#  instructable_id :integer
#  start_time      :datetime
#  end_time        :datetime
#  location        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe Instance do
  pending "add some examples to (or delete) #{__FILE__}"
end
