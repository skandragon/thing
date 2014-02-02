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
    log_in tracks: ["Artisan's Row", 'Middle Eastern', 'Pennsic University', 'Games']

    @user = create(:instructor)
    @instructables = []
    create_instructables(10, track: 'Middle Eastern', user_id: @user.id)
    create_instructables(10, track: 'Pennsic University', user_id: @user.id)

    @scheduled = create(:instructable, track: 'Middle Eastern', name: 'Flarg', user_id: @user.id)
    @scheduled_instance = create(:instance, instructable_id: @scheduled.id, start_time: get_date(0) + 21.hours, location: 'A&S 6')
    @instructables << @scheduled
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

    it "should require a track to be selected for location" do
      visit coordinator_locations_path
      within '#location-form' do
        select Instructable::CLASS_DATES.first, from: 'date'
        click_on 'Go'
      end
      page.should have_content 'Select both a date and a track'
    end

    it "should require a date to be selected for location" do
      visit coordinator_locations_path
      within '#location-form' do
        select 'Pennsic University', from: 'track'
        click_on 'Go'
      end
      page.should have_content 'Select both a date and a track'
    end

    it "should require a track they are coordinator for location", js: true do
      visit coordinator_locations_path
      click_on 'HACKIT'
      sleep(0.25)
      within '#location-form' do
        select Instructable::CLASS_DATES.first, from: 'date'
        select 'BadBogusValue', from: 'track'
        click_on 'Go'
      end
      page.should have_content 'Select a valid date and track you are'
    end

    it "should say if there are no classes for that track" do
      visit coordinator_locations_path
      within '#location-form' do
        select Instructable::CLASS_DATES.first, from: 'date'
        select 'Games', from: 'track'
        click_on 'Go'
      end
      page.should have_content 'There are no instances of'
    end

    it "should require a track to be selected for free/busy" do
      visit coordinator_locations_path
      within '#freebusy-form' do
        click_on 'Go'
      end
      page.should have_content 'Select a track'
    end

    it "should require a track they are coordinator for free/busy", js: true do
      visit coordinator_locations_path
      click_on 'HACKIT'
      sleep(0.25)
      within '#freebusy-form' do
        select 'BadBogusValue', from: 'track'
        click_on 'Go'
      end
      page.should have_content 'Select a track you are coordinator for'
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

    it 'renders pdf' do
      visit timesheets_coordinator_locations_path(format: :pdf, track: 'Pennsic University', date: Instructable::CLASS_DATES[1])
      page.response_headers['Content-Type'].should == 'application/pdf'
      page.body.should_not be_blank
      page.body[0..3].should == '%PDF'
    end

    it "renders all days for Artisan's Row" do
      visit timesheets_coordinator_locations_path(format: :pdf, track: "Artisan's Row", date: Instructable::CLASS_DATES[1])
      page.response_headers['Content-Type'].should == 'application/pdf'
      page.body.should_not be_blank
      page.body[0..3].should == '%PDF'
    end
  end

  describe '#freebusy' do
    it 'should render all tables and track locations' do
      visit freebusy_coordinator_locations_path(track: 'Pennsic University')
      Instructable::CLASS_DATES.each do |date|
        within(:css, "table\##{date}") do
          within(:xpath, './/thead/tr[1]') do
            Instructable::TRACKS['Pennsic University'].each do |location|
              page.should have_content(location)
            end
          end
        end
      end
    end

    it 'should render our instance in a specific location' do
      date = Instructable::CLASS_DATES.first
      visit freebusy_coordinator_locations_path(track: 'Pennsic University')
      within(:xpath, "//table[@id='#{date}']/tbody/tr[13]/td[6]") do
        page.should have_content(@scheduled_instance.id.to_s)
      end
    end
  end
end
