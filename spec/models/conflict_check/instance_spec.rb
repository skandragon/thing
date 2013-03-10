require 'spec_helper'

describe ConflictCheck::Instance do
  describe "time_overlap?" do
    def i1
      @i1 ||= create(:instructable, duration: 3)
    end

    def i2
      @i2 ||= create(:instructable, duration: 3)
    end

    before :each do
      @i1 = nil
      @i2 = nil
    end

    it "does if b.start_time between a.start_time/end_time" do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: get_date(0, 1) + 1)
      ConflictCheck::Instance.time_overlap?(a, b).should be_true
    end

    it "does if b.end_time between a.start_time/end_time" do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: get_date(0, 1) - 1)
      ConflictCheck::Instance.time_overlap?(a, b).should be_true
    end

    it "does not for a.end_time = b.start_time" do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: a.end_time)
      ConflictCheck::Instance.time_overlap?(a, b).should be_false
    end

    it "does not for a.start_time = b.end_time" do
      b = i1.instances.create!(start_time: get_date(0, 1))
      a = i1.instances.create!(start_time: b.end_time)
      ConflictCheck::Instance.time_overlap?(a, b).should be_false
    end

    it "does not if a.start_time is nil" do
      a = i1.instances.create!
      b = i1.instances.create!(start_time: get_date(0, 1))
      ConflictCheck::Instance.time_overlap?(a, b).should be_false
    end

    it "does not if b.start_time is nil" do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!
      ConflictCheck::Instance.time_overlap?(a, b).should be_false
    end

    it "does not if both a and b.start_time are nil" do
      a = i1.instances.create!
      b = i1.instances.create!
      ConflictCheck::Instance.time_overlap?(a, b).should be_false
    end
  end

  describe "location_overlap?" do
    describe "Not in a camp" do
      before :each do
        @ia = create(:instructable)
        @ib = create(:instructable)
      end

      it "does not if a.location is blank" do
        a = @ia.instances.create!
        b = @ib.instances.create!(location: "A&S 1")
        ConflictCheck::Instance.location_overlap?(a, b).should be_false
      end

      it "does not if b.location is blank" do
        a = @ib.instances.create!(location: "A&S 1")
        b = @ia.instances.create!
        ConflictCheck::Instance.location_overlap?(a, b).should be_false
      end

      it "does not if both locations are blank" do
        a = @ia.instances.create!
        b = @ib.instances.create!
        ConflictCheck::Instance.location_overlap?(a, b).should be_false
      end

      it "does if a.location == b.location" do
        a = @ia.instances.create!(location: "A&S 1")
        b = @ib.instances.create!(location: "A&S 1")
        ConflictCheck::Instance.location_overlap?(a, b).should be_true
      end
    end

    describe "both in camps" do
      it "in the same camp does" do
        @ia = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: "Foo", camp_reason: "bar")
        @ib = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: "Foo", camp_reason: "bar")
        @a = @ia.instances.create!
        @b = @ib.instances.create!
        ConflictCheck::Instance.location_overlap?(@a, @b).should be_true
      end

      it "in different camps does not" do
        @ia = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: "Foo", camp_reason: "bar")
        @ib = create(:instructable, location_type: 'private-camp', camp_name: 'bar', camp_address: "Foo", camp_reason: "bar")
        @a = @ia.instances.create!
        @b = @ib.instances.create!
        ConflictCheck::Instance.location_overlap?(@a, @b).should be_false
      end
    end

    describe "one in camp" do
      it "a in camp, b not" do
        @ia = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: "Foo", camp_reason: "bar")
        @ib = create(:instructable)
        @a = @ia.instances.create!
        @b = @ib.instances.create!(location: 'A&S 1')
        ConflictCheck::Instance.location_overlap?(@a, @b).should be_false
      end

      it "a not in camp, b in camp" do
        @ia = create(:instructable)
        @ib = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: "Foo", camp_reason: "bar")
        @a = @ia.instances.create!(location: 'A&S 1')
        @b = @ib.instances.create!
        ConflictCheck::Instance.location_overlap?(@a, @b).should be_false
      end
    end
  end
end
