# == Schema Information
#
# Table name: instances
#
#  id                :integer          not null, primary key
#  instructable_id   :integer
#  start_time        :datetime
#  end_time          :datetime
#  location          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  override_location :boolean
#  year              :integer
#

require 'rails_helper'

describe Instance do
  describe 'updates end time' do
    before :each do
      @instructable = create(:instructable, duration: 6)
      @instance = @instructable.instances.create!(start_time: get_date(1), location: 'There')
    end

    it 'updates end time on save' do
      expect(@instance.end_time.to_s).to eql get_date(1, 6.hours).to_s
      @instance.start_time = get_date(1, 1.hour)
      @instance.save!
      expect(@instance.end_time.to_s).to eql get_date(1, 7.hours).to_s
    end
  end

  describe 'start date' do
    it 'rejects out of range dates' do
      instance = build(:instance, start_time: '2000-01-01')
      expect(instance).to_not be_valid
      expect(instance.errors[:start_time]).to_not be_empty
    end

    it 'accepts bogus dates if overridden' do
      instance = build(:instance, override_location: true, start_time: '2000-01-01')
      expect(instance).to be_valid
    end
  end

  describe '#formatted_location' do
    it 'renders private camp correctly' do
      instructable = create(:instructable, location_type: 'private-camp', camp_reason: 'because', camp_address: 'N06', camp_name: 'Flarg')
      instance = instructable.instances.create
      expect(instance.formatted_location).to eql 'Flarg (N06)'
    end

    it 'renders merchant booth correctly' do
      instructable = create(:instructable, location_type: 'merchant-booth', camp_reason: 'because', camp_address: 'N06', camp_name: 'Flarg')
      instance = instructable.instances.create
      expect(instance.formatted_location).to eql 'Flarg (N06)'
    end

    it 'renders pennsic location correctly' do
      instructable = create(:instructable, location_type: 'track')
      instance = instructable.instances.create!(location: 'Flarg')
      expect(instance.formatted_location).to eql 'Flarg'
    end

    it 'handles blank camp_address' do
      instructable = create(:instructable, location_type: 'private-camp', camp_reason: 'because', camp_name: 'Flarg')
      instance = instructable.instances.create
      expect(instance.formatted_location).to eql 'Flarg'
    end

    it 'handles blank location' do
      instructable = create(:instructable, location_type: 'track')
      instance = instructable.instances.create
      expect(instance.formatted_location).to be_blank
    end
  end

  describe '#formatted_location_and_time' do
    before :each do
      @time = get_date(1, 14 * 3600)
    end

    it 'Renders times' do
      instructable = create(:instructable, location_type: 'track')
      instance = instructable.instances.create(start_time: @time)
      expect(instance.formatted_location_and_time).to include("#{@time.to_s(:pennsic_short).gsub('  ', ' ')}")
      expect(instance.formatted_location_and_time).to include('Location pending')
    end

    it "renders 'time pending' for locationless unscheduled" do
      instructable = create(:instructable, location_type: 'track')
      instance = instructable.instances.create(start_time: nil, location: '')
      expect(instance.formatted_location_and_time).to eql 'Location and time pending'
    end

    it "renders ', time pending' for locationed unscheduled" do
      instructable = create(:instructable, location_type: 'track')
      instance = instructable.instances.create(start_time: nil, location: 'A&S 1')
      expect(instance.formatted_location_and_time).to include 'time pending'
      expect(instance.formatted_location_and_time).to include 'A&S 1'
    end
  end
end
