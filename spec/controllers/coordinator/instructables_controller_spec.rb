require 'rails_helper'

describe Coordinator::InstructablesController, type: :controller do
  def setup_data
    user = create(:user)
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Performing Arts and Music', name: 'MEMusicUnscheduledUnapproved')
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Dance', name: 'MEDanceUnscheduledApproved',
           approved: true)
    @meclass = create(:instructable, user_id: user.id, track: 'Middle Eastern',
               topic: 'History', name: 'MEHistoryScheduledApproved',
               approved: true)
    @meclass.instances.create!(start_time: get_date(0), location: 'Foo')
    @paclass = create(:instructable, user_id: user.id, track: 'Performing Arts and Music',
               topic: 'History', name: 'PAHistoryScheduledApproved',
               approved: true)
    @paclass.instances.create!(start_time: get_date(1), location: 'Foo')
    create(:instructable, user_id: user.id, track: 'Archery',
           topic: 'Martial', name: 'ArcheryUnscheduledUnapproved')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Martial', name: 'TracklessArchery')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Performing Arts and Music', name: 'TracklessMusic')
  end

  describe 'search (admin)' do
    before :each do
      setup_data
      log_in tracks: ['Middle Eastern'], admin: true
      visit coordinator_instructables_path
    end

    it 'renders as admin' do
      select '(track)', from: 'track'
      click_on 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to have_content 'MEDanceUnscheduledApproved'
      expect(page).to have_content 'MEHistoryScheduledApproved'
      expect(page).to have_content 'PAHistoryScheduledApproved'
    end

    it 'renders as admin for other tracks' do
      select 'Performing Arts and Music', from: 'track'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to_not have_content 'MEDanceUnscheduledApproved'
      expect(page).to_not have_content 'MEHistoryScheduledApproved'
      expect(page).to have_content 'PAHistoryScheduledApproved'
    end

    it 'renders as admin for trackless classes' do
      select 'No Track', from: 'track'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to_not have_content 'MEDanceUnscheduledApproved'
      expect(page).to_not have_content 'MEHistoryScheduledApproved'
      expect(page).to_not have_content 'PAHistoryScheduledApproved'
      expect(page).to have_content 'TracklessMusic'
    end

    it 'allows admin to select any track' do
      expect(page).to have_select('track')
      Instructable::TRACKS.keys.each { |tract|
        select tract, from: 'track'
      }
    end
  end

  describe 'search (multi-track coordinator)' do
    before :each do
      setup_data
      log_in tracks: ['Middle Eastern', 'Performing Arts and Music']
      visit coordinator_instructables_path
    end

    it 'allows selection of track' do
      expect(page).to have_select('track')
      current_user.allowed_tracks.each { |tract|
        select tract, from: 'track'
      }
    end

    it 'ignores disallowed track filter' do
      visit coordinator_instructables_path(track: 'Archery')
      expect(page).to_not have_content 'Archery'
    end
  end

  describe 'search (single-track coordinator)' do
    before :each do
      setup_data
      log_in tracks: ['Middle Eastern']
      visit coordinator_instructables_path
    end

    it 'renders as coordinator' do
      expect(page).to have_button 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to have_content 'MEDanceUnscheduledApproved'
      expect(page).to have_content 'MEHistoryScheduledApproved'
      expect(page).to_not have_content 'PAHistoryScheduledApproved'
    end

    it 'allows selection of track' do
      expect(page).to_not have_select('track')
    end

    it 'filters based on scheduled = 1' do
      select 'Scheduled', from: 'scheduled'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to_not have_content 'MEDanceUnscheduledApproved'
      expect(page).to have_content 'MEHistoryScheduledApproved'
      expect(page).to have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on scheduled = 0' do
      select 'Not Scheduled', from: 'scheduled'
      click_on 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to have_content 'MEDanceUnscheduledApproved'
      expect(page).to_not have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on topic' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to have_content 'MEDanceUnscheduledApproved'
      expect(page).to_not have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on partial class name' do
      fill_in 'search', with: 'Unscheduled'
      click_on 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to have_content 'MEDanceUnscheduledApproved'
      expect(page).to_not have_content 'MEHistoryScheduledApproved'
    end

    it 'filters based on start date' do
      target = @meclass.instances.first.start_time.strftime('%Y-%m-%d')
      select target, from: 'date'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to_not have_content 'MEDanceUnscheduledApproved'
      expect(page).to_not have_content 'PAHistoryScheduledApproved'
      expect(page).to have_content 'MEHistoryScheduledApproved'
    end

    it 'clears the form' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      click_on 'Clear'
      expect(page).to have_content 'MEMusicUnscheduledUnapproved'
      expect(page).to have_content 'MEDanceUnscheduledApproved'
      expect(page).to have_content 'MEHistoryScheduledApproved'
    end
  end
end
