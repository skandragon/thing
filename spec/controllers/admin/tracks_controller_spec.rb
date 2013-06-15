require 'spec_helper'

describe Admin::TracksController do
  it 'requires admin' do
    visit admin_tracks_path
    page.should have_content('Not authorized')
  end

  describe 'index' do
    before :each do
      log_in admin: true
    end

    it 'renders' do
      visit admin_tracks_path
      Instructable::TRACKS.keys.each { |track|
        page.should have_content track
      }
    end

    it "displays 'No classes'" do
      visit admin_tracks_path
      first('.badge') do
        should have_content 'No classes'
      end
    end

    it 'renders 50% for a track' do
      i1 = create(:instructable, track: 'Middle Eastern')
      i1.instances.create!(start_time: get_date(0), location: 'Touch the Earch')
      create(:instructable, track: 'Middle Eastern')
      visit admin_tracks_path
      first('.badge.badge-warning') do
        should have_content('50.00%')
      end
    end

    it 'renders 100% for a track' do
      i1 = create(:instructable, track: 'Middle Eastern')
      i1.instances.create!(start_time: get_date(0), location: 'Touch the Earch')
      visit admin_tracks_path
      first('.badge.badge-success') do
        should have_content('100.00%')
      end
    end
  end
end
