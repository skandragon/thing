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
  before :each do
    @instructable = create(:instructable, duration: 6)
    @instance = @instructable.instances.create(start_time: '2013-01-01 00:00:00', location: "There")
  end

  it "updates end time on save" do
    @instance.end_time.to_s(:number).should == Time.parse('2013-01-01 06:00:00').to_s(:number)
    @instance.start_time = '2013-01-01 01:00:00'
    @instance.save!
    @instance.end_time.to_s(:number).should == Time.parse('2013-01-01 07:00:00').to_s(:number)
  end
end
