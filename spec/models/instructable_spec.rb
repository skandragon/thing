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
#  handout_fee               :float
#  material_fee              :float
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  duration                  :float
#  culture                   :string(255)
#  topic                     :string(255)
#  subtopic                  :string(255)
#  description_book          :text
#  additional_instructors    :string(255)      is an Array
#  camp_name                 :string(255)
#  camp_address              :string(255)
#  camp_reason               :string(255)
#  adult_only                :boolean          default(FALSE)
#  adult_reason              :string(255)
#  fee_itemization           :text
#  requested_days            :date             is an Array
#  repeat_count              :integer          default(0)
#  scheduling_additional     :text
#  special_needs             :string(255)      is an Array
#  special_needs_description :text
#  heat_source               :boolean          default(FALSE)
#  heat_source_description   :text
#  requested_times           :string(255)      is an Array
#  track                     :string(255)
#  scheduled                 :boolean          default(FALSE)
#  location_type             :string(255)      default("track")
#  proofread                 :boolean          default(FALSE)
#  proofread_by              :integer          default([]), is an Array
#  proofreader_comments      :text
#  year                      :integer
#  schedule                  :string(255)
#  info_tag                  :string(255)
#

require 'rails_helper'

describe Instructable do
  before :each do
    @instructable = build(:instructable)
  end

  it 'baseline validations' do
    expect(@instructable).to be_valid
  end

  it 'requires fee_itemization if handout_fee' do
    @instructable.handout_fee = 10
    expect(@instructable).to_not be_valid
    expect(@instructable.errors_on(:fee_itemization)).to include("can't be blank")
  end

  it 'requires fee_itemization if material_fee' do
    @instructable.material_fee = 10
    expect(@instructable).to_not be_valid
    expect(@instructable.errors_on(:fee_itemization)).to include("can't be blank")
  end

  describe 'validation of subtopic' do
    it 'fails for invalid subtopic' do
      @instructable.topic = 'Martial'
      @instructable.subtopic = 'XXX'
      expect(@instructable).to_not be_valid
    end

    it 'passes for valid subtopic' do
      @instructable.topic = 'Martial'
      @instructable.subtopic = 'Archery'
      expect(@instructable).to be_valid
    end

    it 'passes for blank subtopic' do
      @instructable.topic = 'Martial'
      @instructable.subtopic = ''
      expect(@instructable).to be_valid
    end
  end

  describe '#status_message' do
    it 'not approved' do
      @instructable.approved = false
      expect(@instructable.status_message).to eql 'Pending Approval'
    end

    it 'approved but not scheduled' do
      @instructable.approved = true
      expect(@instructable.status_message).to eql 'Pending Scheduling'
    end

    it 'approved but not fully scheduled' do
      @instructable.approved = true
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0], location: 'foo')
      @instructable.reload
      expect(@instructable.status_message).to eql 'Pending Scheduling'
    end

    it 'approved and scheduled' do
      @instructable.approved = true
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0], location: 'foo')
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[1], location: 'foo')
      @instructable.reload
      expect(@instructable.status_message).to eql 'Approved and Scheduled'
    end

    it 'approved but missing one or more items to be fully scheduled' do
      @instructable.approved = true
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0])
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[1], location: 'foo')
      @instructable.reload
      expect(@instructable.status_message).to eql 'Pending Scheduling'
    end

    it 'approved and in a camp' do
      @instructable.approved = true
      @instructable.location_type = 'private-camp'
      @instructable.camp_name = 'Flarg'
      @instructable.camp_address = 'Flarg'
      @instructable.camp_reason = 'Flarg'
      @instructable.repeat_count = 2
      @instructable.save!
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[0])
      @instructable.instances.create!(start_time: Instructable::CLASS_DATES[1])
      @instructable.reload
      expect(@instructable.status_message).to eql 'Approved and Scheduled'
    end
  end

  describe '#formatted_culture_and_topic' do
    it 'renders with culture, topic, and subtopic' do
      @instructable.culture = 'culture'
      @instructable.topic = 'topic'
      @instructable.subtopic = 'subtopic'
      expect(@instructable.formatted_culture_and_topic).to eql 'culture: topic: subtopic'
    end

    it 'renders with culture and topic' do
      @instructable.culture = 'culture'
      @instructable.topic = 'topic'
      @instructable.subtopic = ''
      expect(@instructable.formatted_culture_and_topic).to eql 'culture: topic'
    end

    it 'renders with only topic' do
      @instructable.culture = ''
      @instructable.topic = 'topic'
      @instructable.subtopic = ''
      expect(@instructable.formatted_culture_and_topic).to eql 'topic'
    end
  end

  describe '#additional_instructables_expanded' do
    it 'encodes into array' do
      @instructable.additional_instructors_expanded = 'This, That, Those'
      expect(@instructable.additional_instructors).to eql ['This', 'That', 'Those']
    end

    it 'decodes into string' do
      @instructable.additional_instructors = [ 'Alpha', 'Beta', 'Zulu' ]
      expect(@instructable.additional_instructors_expanded).to eql 'Alpha, Beta, Zulu'
    end
  end

  describe 'fees of to_f == 0.0 convert into nil' do
    it 'converts handout_fee' do
      @instructable.handout_fee = '0.0'
      expect(@instructable).to be_valid
    end

    it 'converts material_fee' do
      @instructable.material_fee = '0.0'
      expect(@instructable).to be_valid
    end
  end

  describe 'fees are floating values' do
    it 'accepts 1.5 for handout_fee' do
      @instructable.handout_fee = '1.5'
      expect(@instructable.handout_fee).to eql 1.5
    end

    it 'accepts 1.5 for masterial_fee' do
      @instructable.material_fee = '1.5'
      expect(@instructable.material_fee).to eql 1.5
    end
  end

  describe '#cleanup_needed_instances' do
    before :each do
      @instructable = create(:instructable, repeat_count: 3)
    end

    it 'does nothing if instance count == needed' do
      @instructable.repeat_count.times do
        @instructable.instances.create!
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      expect(@instructable.instances.count).to eql @instructable.repeat_count
    end

    it 'does nothing if instance count < needed' do
      @instructable.instances.create!
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      expect(@instructable.instances.count).to eql 1
    end

    it 'removes extra instances if blank ones are present' do
      5.times do
        @instructable.instances.create!
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      expect(@instructable.instances.count).to eql @instructable.repeat_count
    end

    it 'removes extra instances if blank start_times are present' do
      5.times do
        @instructable.instances.create!(location: 'A&S 1')
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      expect(@instructable.instances.count).to eql @instructable.repeat_count
    end

    it 'removes the oldest entries if start_time is set' do
      5.times do |n|
        @instructable.instances.create!(start_time: get_date(n + 1), location: 'A&S 1')
      end
      @instructable.cleanup_unneeded_instances
      @instructable.reload
      expect(@instructable.instances.count).to eql @instructable.repeat_count
      found = @instructable.instances.pluck(:start_time).sort
      expect(found).to eql [get_date(1), get_date(2), get_date(3)]
    end
  end

  describe 'proofread' do
    describe 'on self-update' do
      before :each do
        @instructable = create(:instructable)
        @instructable.reload
        @instructable.proofread_by = [123]
        @instructable.is_proofreader = 123
        @instructable.save!
        @instructable.is_proofreader = false
        @instructable.reload
      end

      it 'on name change' do
        expect(@instructable.proofread).to_not be_truthy
        expect(@instructable.proofread_by).to eql [123]
        @instructable.name = 'Flarg'
        @instructable.is_proofreader = 123
        @instructable.save!
        @instructable.reload
        expect(@instructable.proofread).to_not be_truthy
        expect(@instructable.proofread_by).to eql [123]
      end
    end

    describe 'on update' do
      before :each do
        @instructable = create(:instructable)
        @instructable.reload
        @instructable.proofread_by = [123, 456]
        @instructable.proofread = true
        @instructable.is_proofreader = 123
        @instructable.save!
        @instructable.is_proofreader = false
        @instructable.reload
      end

      it 'clears on name change' do
        expect(@instructable.proofread).to be_truthy
        @instructable.name = 'Flarg'
        @instructable.save!
        @instructable.reload
        expect(@instructable.proofread).to_not be_truthy
        expect(@instructable.proofread_by).to be_empty
      end

      it 'unaffected on duration change' do
        expect(@instructable.proofread).to be_truthy
        @instructable.duration = @instructable.duration + 1
        @instructable.save!
        @instructable.reload
        expect(@instructable.proofread).to be_truthy
        expect(@instructable.proofread_by).to_not be_empty
      end

      it 'clears on new proofreader, on name change' do
        expect(@instructable.proofread).to be_truthy
        @instructable.name = 'Flarg'
        @instructable.is_proofreader = 987
        @instructable.save!
        @instructable.reload
        expect(@instructable.proofread).to_not be_truthy
        expect(@instructable.proofread_by).to eql [ 987 ]
      end

      it 'does not clear on new proofreader, on uninteresting change' do
        expect(@instructable.proofread).to be_truthy
        @instructable.duration = @instructable.duration + 1
        @instructable.is_proofreader = 987
        @instructable.save!
        @instructable.reload
        expect(@instructable.proofread).to be_truthy
        expect(@instructable.proofread_by).to include(987)
      end
    end
  end

  describe '::locations' do
    it 'renders all' do
      locations = Instructable::locations
      keys = locations.keys
      expect(keys).to include 'A&S 2'

      items = locations['A&S 2']
      expect(items).to include 'Pennsic University'
      expect(items).to include 'Heraldry'
    end

    it 'renders just for specific tracks' do
      locations = Instructable::locations('Pennsic University')
      keys = locations.keys
      expect(keys).to include 'A&S 2'

      items = locations['A&S 2']
      expect(items).to include 'Pennsic University'
      expect(items.size).to eql 1
    end
  end

  it 'updates instances on duration change' do
    instructable = create(:scheduled_instructable, duration: 4.0)
    instructable.reload
    instance = instructable.instances.first

    expect(instance.end_time - instance.start_time).to eql 4.0 * 3600

    instructable.duration = 5.0
    instructable.save!

    instructable.reload
    instance.reload

    expect(instructable.duration).to eql 5.0
    expect(instance.end_time - instance.start_time).to eql 5.0 * 3600
  end

  it 'updates instances on location change' do
    instructable = create(:scheduled_instructable, camp_name: 'Flarg', location_type: 'private-camp', camp_reason: "Because")
    instructable.reload
    instance = instructable.instances.first

    expect(instance.location).to eql 'Flarg'

    instructable.location_type = 'track'
    instructable.save!

    instance.reload
    expect(instance.location).to_not be_blank
  end

  it 'clears info_tag if the topic changes' do
    instructable = create(:instructable, info_tag: '12345', topic: Instructable::TOPICS.keys[0])
    instructable.reload

    expect(instructable.info_tag).to eql '12345'

    instructable.topic = Instructable::TOPICS.keys[1]
    expect(instructable.info_tag).to be_blank
  end
end
