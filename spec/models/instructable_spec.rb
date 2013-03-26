# == Schema Information
#
# Table name: instructables
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  approved                  :boolean          default(FALSE)
#  name                      :string(255)
#  material_limit            :integer
#  handout_limit             :integer
#  description_web           :text
#  handout_fee               :integer
#  material_fee              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  duration                  :float
#  culture                   :string(255)
#  topic                     :string(255)
#  subtopic                  :string(255)
#  description_book          :text
#  additional_instructors    :string(255)
#  camp_name                 :string(255)
#  camp_address              :string(255)
#  camp_reason               :string(255)
#  adult_only                :boolean          default(FALSE)
#  adult_reason              :string(255)
#  fee_itemization           :text
#  requested_days            :date
#  repeat_count              :integer          default(0)
#  scheduling_additional     :text
#  special_needs             :string(255)
#  special_needs_description :text
#  heat_source               :boolean          default(FALSE)
#  heat_source_description   :text
#  requested_times           :string(255)
#  track                     :string(255)
#  scheduled                 :boolean          default(FALSE)
#  location_type             :string(255)      default("track")
#  proofread                 :boolean          default(FALSE)
#

require 'spec_helper'

describe Instructable do
  before :each do
    @instructable = build(:instructable)
  end

  it "baseline validations" do
    @instructable.should be_valid
  end

  describe 'validation of subtopic' do
    it "fails for invalid subtopic" do
      @instructable.topic = 'Martial'
      @instructable.subtopic = 'XXX'
      @instructable.should_not be_valid
    end

    it "passes for valid subtopic" do
      @instructable.topic = 'Martial'
      @instructable.subtopic = 'Archery'
      @instructable.should be_valid
    end

    it "passes for blank subtopic" do
      @instructable.topic = 'Martial'
      @instructable.subtopic = ''
      @instructable.should be_valid
    end
  end

  describe '#status_message' do
    it 'not approved' do
      @instructable.approved = false
      @instructable.status_message.should == 'Pending Approval'
    end

    it 'approved but not scheduled' do
      @instructable.approved = true
      @instructable.status_message.should == 'Pending Scheduling'
    end

    it 'approved but not fully scheduled' do
      @instructable.approved = true
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0], location: "foo")
      @instructable.reload
      @instructable.status_message.should == 'Pending Scheduling'
    end

    it 'approved and scheduled' do
      @instructable.approved = true
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0], location: "foo")
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[1], location: "foo")
      @instructable.reload
      @instructable.status_message.should == 'Approved and Scheduled'
    end

    it 'approved but missing one or more items to be fully scheduled' do
      @instructable.approved = true
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0])
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[1], location: "foo")
      @instructable.reload
      @instructable.status_message.should == 'Pending Scheduling'
    end

    it 'approved and in a camp' do
      @instructable.approved = true
      @instructable.location_type = 'private-camp'
      @instructable.camp_name = "Flarg"
      @instructable.camp_address = "Flarg"
      @instructable.camp_reason = "Flarg"
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0])
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[1])
      @instructable.reload
      @instructable.status_message.should == 'Approved and Scheduled'
    end
  end

  describe '#formatted_culture_and_topic' do
    it "renders with culture, topic, and subtopic" do
      @instructable.culture = "culture"
      @instructable.topic = "topic"
      @instructable.subtopic = "subtopic"
      @instructable.formatted_culture_and_topic.should == "culture: topic: subtopic"
    end

    it "renders with culture and topic" do
      @instructable.culture = "culture"
      @instructable.topic = "topic"
      @instructable.subtopic = ""
      @instructable.formatted_culture_and_topic.should == "culture: topic"
    end

    it "renders with only topic" do
      @instructable.culture = ""
      @instructable.topic = "topic"
      @instructable.subtopic = ""
      @instructable.formatted_culture_and_topic.should == "topic"
    end
  end

  describe '#additional_instructables_expanded' do
    it 'encodes into array' do
      @instructable.additional_instructors_expanded = "This, That, Those"
      @instructable.additional_instructors.should == ['This', 'That', 'Those']
    end

    it 'decodes into string' do
      @instructable.additional_instructors = [ 'Alpha', 'Beta', 'Zulu' ]
      @instructable.additional_instructors_expanded.should == 'Alpha, Beta, Zulu'
    end
  end

  describe "fees of to_f == 0.0 convert into nil" do
    it "converts handout_fee" do
      @instructable.handout_fee = "0.0"
      @instructable.should be_valid
    end

    it "converts material_fee" do
      @instructable.material_fee = "0.0"
      @instructable.should be_valid
    end
  end

  describe '#cleanup_needed_instances' do
    before :each do
      @instructable = create(:instructable, repeat_count: 3)
    end

    it "does nothing if instance count == needed" do
      @instructable.repeat_count.times do
        @instructable.instances.create!
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      @instructable.instances.count.should == @instructable.repeat_count
    end

    it "does nothing if instance count < needed" do
      @instructable.instances.create!
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      @instructable.instances.count.should == 1
    end

    it "removes extra instances if blank ones are present" do
      5.times do
        @instructable.instances.create!
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      @instructable.instances.count.should == @instructable.repeat_count
    end

    it "removes extra instances if blank start_times are present" do
      5.times do
        @instructable.instances.create!(location: 'A&S 1')
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      @instructable.instances.count.should == @instructable.repeat_count
    end

    it "removes the oldest entries if start_time is set" do
      5.times do |n|
        @instructable.instances.create!(start_time: get_date(n + 1), location: 'A&S 1')
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      @instructable.instances.count.should == @instructable.repeat_count
      found = @instructable.instances.pluck(:start_time).sort
      found.should == [get_date(1), get_date(2), get_date(3)]
    end
  end

  describe "proofread" do
    describe "on update" do
      before :each do
        @instructable = create(:instructable, proofread: true, is_proofreader: true)
        @instructable = Instructable.find @instructable.id
      end

      it "clears on name change" do
        @instructable.proofread.should be_true
        @instructable.name = "Flarg"
        @instructable.save!
        @instructable.reload
        @instructable.proofread.should_not be_true
      end

      it "unafffected on duration change" do
        @instructable.proofread.should be_true
        @instructable.duration = @instructable.duration + 1
        @instructable.save!
        @instructable.reload
        @instructable.proofread.should be_true
      end
    end
  end
end
