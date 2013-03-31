require 'spec_helper'

describe Coordinator::LocationsController do
  def create_instructables(count, *args)
    count.times do
      instructable = create(:scheduled_instructable, *args)
      instructable.reload
      @instructables << instructable
    end
  end

  def setup_data
    log_in tracks: ['Middle Eastern', 'Pennsic University']

    @instructables = []
    create_instructables(10, track: 'Middle Eastern')
    create_instructables(10, track: 'Pennsic University')
  end

  before :each do
    setup_data
  end

  describe '#index' do
    it 'renders' do
      visit coordinator_locations_path

      current_user.allowed_tracks.each do |track|
        page.should have_content track
      end

      Instructable::CLASS_DATES.each do |date|
        page.should have_content date
      end
    end
  end

  describe '#timesheets' do
    it 'redirects on blank track' do
      visit timesheets_coordinator_locations_path(format: :pdf, date: Instructable::CLASS_DATES[1])
      page.should have_content 'Select both'
    end

    it 'redirects on blank date' do
      visit timesheets_coordinator_locations_path(format: :pdf, track: 'Pennsic University')
      page.should have_content 'Select both'
    end
  end
end
