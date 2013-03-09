require 'spec_helper'

describe ConflictCheck::Instance do
  def i1
    @i1 ||= create(:instructable, duration: 3)
  end

  before :each do
    @i1 = nil
  end

  describe "time_overlap?" do
    it "returns true if b.start_time between a.start_time/end_time" do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: get_date(0, 1) + 1)
      ConflictCheck::Instance.time_overlap?(a, b).should be_true
    end

    it "returns true if b.end_time between a.start_time/end_time" do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: get_date(0, 1) - 1)
      ConflictCheck::Instance.time_overlap?(a, b).should be_true
    end

    it "returns false for a.end_time = b.start_time" do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: a.end_time)
      ConflictCheck::Instance.time_overlap?(a, b).should_not be_true
    end

    it "returns false for a.start_time = b.end_time" do
      b = i1.instances.create!(start_time: get_date(0, 1))
      a = i1.instances.create!(start_time: b.end_time)
      ConflictCheck::Instance.time_overlap?(a, b).should_not be_true
    end
  end
end
