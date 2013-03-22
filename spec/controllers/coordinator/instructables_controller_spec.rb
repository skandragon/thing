require 'spec_helper'

describe Coordinator::InstructablesController do
  def setup_data
    user = create(:user)
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Music', name: 'MEMusicUnscheduledUnapproved')
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Dance', name: 'MEDanceUnscheduledApproved',
           approved: true)
    i = create(:instructable, user_id: user.id, track: 'Middle Eastern',
               topic: 'History', name: 'MEHistoryScheduledApproved',
               approved: true)
    i.instances.create(start_time: get_date(0), location: 'Foo')
    i = create(:instructable, user_id: user.id, track: 'Performing Arts',
               topic: 'History', name: 'PAHistoryScheduledApproved',
               approved: true)
    i.instances.create(start_time: get_date(1), location: 'Foo')
    create(:instructable, user_id: user.id, track: 'Archery',
           topic: 'Martial', name: 'ArcheryUnscheduledUnapproved')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Martial', name: 'TracklessArchery')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Music', name: 'TracklessMusic')
  end

  describe 'search (admin)' do
    before :each do
      setup_data
      log_in tracks: ['Middle Eastern'], admin: true
      visit coordinator_instructables_path
    end

    it 'renders as admin' do
      select '', from: 'track'
      click_on 'Filter'
      page.should have_content 'MEMusicUnscheduledUnapproved'
      page.should have_content 'MEDanceUnscheduledApproved'
      page.should have_content 'MEHistoryScheduledApproved'
      page.should have_content 'PAHistoryScheduledApproved'
    end

    it 'renders as admin for other tracks' do
      select 'Performing Arts', from: 'track'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnscheduledUnapproved'
      page.should_not have_content 'MEDanceUnscheduledApproved'
      page.should_not have_content 'MEHistoryScheduledApproved'
      page.should have_content 'PAHistoryScheduledApproved'
    end

    it 'renders as admin for trackless classes' do
      select 'No Track', from: 'track'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnscheduledUnapproved'
      page.should_not have_content 'MEDanceUnscheduledApproved'
      page.should_not have_content 'MEHistoryScheduledApproved'
      page.should_not have_content 'PAHistoryScheduledApproved'
      page.should have_content 'TracklessMusic'
    end

    it 'allows admin to select any track' do
      page.should have_select('track')
      for tract in Instructable::TRACKS.keys
        select tract, from: 'track'
      end
    end
  end

  describe 'search (multi-track coordinator)' do
    before :each do
      setup_data
      log_in tracks: ['Middle Eastern', 'Performing Arts']
      visit coordinator_instructables_path
    end

    it 'allows selection of track' do
      page.should have_select('track')
      for tract in current_user.allowed_tracks
        select tract, from: 'track'
      end
    end

    it 'ignores disallowed track filter' do
      visit coordinator_instructables_path(track: 'Archery')
      page.should_not have_content 'Archery'
    end
  end

  describe 'search (single-track coordinator)' do
    before :each do
      setup_data
      log_in tracks: ['Middle Eastern']
      visit coordinator_instructables_path
    end

    it 'renders as coordinator' do
      page.should have_button 'Filter'
      page.should have_content 'MEMusicUnscheduledUnapproved'
      page.should have_content 'MEDanceUnscheduledApproved'
      page.should have_content 'MEHistoryScheduledApproved'
      page.should_not have_content 'PAHistoryScheduledApproved'
    end

    it 'allows selection of track' do
      page.should_not have_select('track')
    end

    it 'filters based on approved = 1' do
      select 'Approved', from: 'approved'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnscheduledUnapproved'
      page.should have_content 'MEDanceUnscheduledApproved'
      page.should have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on approved = 0' do
      select 'Not Approved', from: 'approved'
      click_on 'Filter'
      page.should have_content 'MEMusicUnscheduledUnapproved'
      page.should_not have_content 'MEDanceUnscheduledApproved'
      page.should_not have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on scheduled = 1' do
      select 'Scheduled', from: 'scheduled'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnscheduledUnapproved'
      page.should_not have_content 'MEDanceUnscheduledApproved'
      page.should have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on scheduled = 0' do
      select 'Not Scheduled', from: 'scheduled'
      click_on 'Filter'
      page.should have_content 'MEMusicUnscheduledUnapproved'
      page.should have_content 'MEDanceUnscheduledApproved'
      page.should_not have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on topic' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnscheduledUnapproved'
      page.should have_content 'MEDanceUnscheduledApproved'
      page.should_not have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on partial class name' do
      fill_in 'search', with: 'Unscheduled'
      click_on 'Filter'
      page.should have_content 'MEMusicUnscheduledUnapproved'
      page.should have_content 'MEDanceUnscheduledApproved'
      page.should_not have_content 'MEHistoryScheduledApproved'
    end

    it 'clears the form' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      click_on 'Clear'
      page.should have_content 'MEMusicUnscheduledUnapproved'
      page.should have_content 'MEDanceUnscheduledApproved'
      page.should have_content 'MEHistoryScheduledApproved'
    end
  end
end
