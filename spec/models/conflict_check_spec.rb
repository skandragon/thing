require 'rails_helper'

describe ConflictCheck do
  describe 'instance_time_overlap?' do
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

    it 'does if b.start_time between a.start_time/end_time' do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: get_date(0, 1) + 1)
      ConflictCheck.instance_time_overlap?(a, b).should be_truthy
    end

    it 'does if b.end_time between a.start_time/end_time' do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: get_date(0, 1) - 1)
      ConflictCheck.instance_time_overlap?(a, b).should be_truthy
    end

    it 'does not for a.end_time = b.start_time' do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!(start_time: a.end_time)
      ConflictCheck.instance_time_overlap?(a, b).should be_falsey
    end

    it 'does not for a.start_time = b.end_time' do
      b = i1.instances.create!(start_time: get_date(0, 1))
      a = i1.instances.create!(start_time: b.end_time)
      ConflictCheck.instance_time_overlap?(a, b).should be_falsey
    end

    it 'does not if a.start_time is nil' do
      a = i1.instances.create!
      b = i1.instances.create!(start_time: get_date(0, 1))
      ConflictCheck.instance_time_overlap?(a, b).should be_falsey
    end

    it 'does not if b.start_time is nil' do
      a = i1.instances.create!(start_time: get_date(0, 1))
      b = i1.instances.create!
      ConflictCheck.instance_time_overlap?(a, b).should be_falsey
    end

    it 'does not if both a and b.start_time are nil' do
      a = i1.instances.create!
      b = i1.instances.create!
      ConflictCheck.instance_time_overlap?(a, b).should be_falsey
    end
  end

  describe 'instance_location_overlap?' do
    describe 'Not in a camp' do
      before :each do
        @ia = create(:instructable)
        @ib = create(:instructable)
      end

      it 'does not if a.location is blank' do
        a = @ia.instances.create!
        b = @ib.instances.create!(location: 'A&S 1')
        ConflictCheck.instance_location_overlap?(a, b).should be_falsey
      end

      it 'does not if b.location is blank' do
        a = @ib.instances.create!(location: 'A&S 1')
        b = @ia.instances.create!
        ConflictCheck.instance_location_overlap?(a, b).should be_falsey
      end

      it 'does not if both locations are blank' do
        a = @ia.instances.create!
        b = @ib.instances.create!
        ConflictCheck.instance_location_overlap?(a, b).should be_falsey
      end

      it 'does if a.location == b.location' do
        a = @ia.instances.create!(location: 'A&S 1')
        b = @ib.instances.create!(location: 'A&S 1')
        ConflictCheck.instance_location_overlap?(a, b).should be_truthy
      end
    end

    describe 'both in camps' do
      it 'in the same camp does' do
        @ia = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: 'Foo', camp_reason: 'bar')
        @ib = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: 'Foo', camp_reason: 'bar')
        @a = @ia.instances.create!
        @b = @ib.instances.create!
        ConflictCheck.instance_location_overlap?(@a, @b).should be_truthy
      end

      it 'in different camps does not' do
        @ia = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: 'Foo', camp_reason: 'bar')
        @ib = create(:instructable, location_type: 'private-camp', camp_name: 'bar', camp_address: 'Foo', camp_reason: 'bar')
        @a = @ia.instances.create!
        @b = @ib.instances.create!
        ConflictCheck.instance_location_overlap?(@a, @b).should be_falsey
      end
    end

    describe 'one in camp' do
      it 'a in camp, b not' do
        @ia = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: 'Foo', camp_reason: 'bar')
        @ib = create(:instructable)
        @a = @ia.instances.create!
        @b = @ib.instances.create!(location: 'A&S 1')
        ConflictCheck.instance_location_overlap?(@a, @b).should be_falsey
      end

      it 'a not in camp, b in camp' do
        @ia = create(:instructable)
        @ib = create(:instructable, location_type: 'private-camp', camp_name: 'foo', camp_address: 'Foo', camp_reason: 'bar')
        @a = @ia.instances.create!(location: 'A&S 1')
        @b = @ib.instances.create!
        ConflictCheck.instance_location_overlap?(@a, @b).should be_falsey
      end
    end
  end

  describe 'instance_instructor_overlap?' do
    it 'conflicts if user_id equal' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!
      @ib = create(:instructable, user_id: 1)
      @b = @ib.instances.create!
      ConflictCheck.instance_instructor_overlap?(@a, @b).should be_truthy
    end

    it 'does not conflict if user_id unequal' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!
      @ib = create(:instructable, user_id: 2)
      @b = @ib.instances.create!
      ConflictCheck.instance_instructor_overlap?(@a, @b).should be_falsey
    end
  end

  describe 'instance_overlap?' do
    it 'returns [] if time does not overlap at all' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!(start_time: get_date(1))
      @ib = create(:instructable, user_id: 2)
      @b = @ib.instances.create!(start_time: get_date(2))

      ConflictCheck.instance_overlap?(@a, @b).should == []
    end

    it 'returns [:location] if time overlaps and location conflicts' do
      @ia = create(:instructable, user_id: 1, topic: Instructable::TOPICS.keys[0])
      @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')
      @ib = create(:instructable, user_id: 2, topic: Instructable::TOPICS.keys[1])
      @b = @ib.instances.create!(start_time: get_date(1), location: 'A&S 1')

      ConflictCheck.instance_overlap?(@a, @b).should == [:location]
    end

    it 'returns [:instructor] if time overlaps and instructor conflicts' do
      @ia = create(:instructable, user_id: 1, topic: Instructable::TOPICS.keys[0])
      @a = @ia.instances.create!(start_time: get_date(1))
      @ib = create(:instructable, user_id: 1, topic: Instructable::TOPICS.keys[1])
      @b = @ib.instances.create!(start_time: get_date(1))

      ConflictCheck.instance_overlap?(@a, @b).should == [:instructor]
    end

    it 'returns [:topic] if time overlaps and topic conflicts' do
      pending
      @ia = create(:instructable, user_id: 1, topic: Instructable::TOPICS.keys[1])
      @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')
      @ib = create(:instructable, user_id: 2, topic: Instructable::TOPICS.keys[1])
      @b = @ib.instances.create!(start_time: get_date(1), location: 'A&S 2')

      ret = ConflictCheck.instance_overlap?(@a, @b)
      ret.should == [:topic]
    end

    it 'returns [:location, :instructor] if time overlaps and both location and instructor conflict' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')
      @ib = create(:instructable, user_id: 1)
      @b = @ib.instances.create!(start_time: get_date(1), location: 'A&S 1')

      ret = ConflictCheck.instance_overlap?(@a, @b)
      ret.should include(:location)
      ret.should include(:instructor)
    end
  end

  describe 'conflicts' do
    it 'returns [] if no instances exist' do
      conflicts = ConflictCheck.conflicts
      conflicts.should be_a(Array)
      conflicts.should == []
    end

    it 'returns [] if only one instance exists' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')

      conflicts = ConflictCheck.conflicts
      conflicts.should be_a(Array)
      conflicts.should == []
    end

    it 'returns [] if time does not overlap at all' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!(start_time: get_date(1))
      @ib = create(:instructable, user_id: 2)
      @b = @ib.instances.create!(start_time: get_date(2))

      conflicts = ConflictCheck.conflicts
      conflicts.should be_a(Array)
      conflicts.should == []
    end

    it 'returns location and instances if it conflicts' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')
      @ib = create(:instructable, user_id: 2, topic: Instructable::TOPICS.keys[1])
      @b = @ib.instances.create!(start_time: get_date(1), location: 'A&S 1')

      conflicts = ConflictCheck.conflicts
      conflicts.should be_a(Array)
      conflicts.size.should == 1
      conflicts[0][0].should == [:location]
      conflicts[0][1].should include(@b)
      conflicts[0][1].should include(@b)
    end

    it 'applies track filter' do
      @ia = create(:instructable, user_id: 1, track: 'Pennsic University')
      @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')
      @ib = create(:instructable, user_id: 2, track: 'Middle Eastern', topic: Instructable::TOPICS.keys[1])
      @b = @ib.instances.create!(start_time: get_date(1), location: 'A&S 1')

      conflicts = ConflictCheck.conflicts(track: 'Pennsic University')
      conflicts.should be_a(Array)
      conflicts.size.should == 1
      conflicts[0][0].should == [:location]
      conflicts[0][1].should include(@b)
      conflicts[0][1].should include(@b)
    end

    it 'returns nothing when all filtered' do
      @ia = create(:instructable, user_id: 1)
      @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')
      @ib = create(:instructable, user_id: 2)
      @b = @ib.instances.create!(start_time: get_date(1), location: 'A&S 1')

      conflicts = ConflictCheck.conflicts(track: 'Archery')
      conflicts.should be_a(Array)
      conflicts.size.should == 0
    end
  end
end
