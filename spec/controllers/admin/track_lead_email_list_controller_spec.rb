require 'rails_helper'

describe Admin::TrackLeadEmailListController, type: :controller do
  it 'requires admin' do
    visit admin_track_lead_email_list_index_path
    page.should have_content('Not authorized')
  end

  describe 'listing' do
    it 'renders only track lead email addresses' do
      some_track_lead = create(:instructor, tracks: ['Middle Eastern'])
      2.times do
        create(:instructor)
      end
      log_in admin: true
      visit admin_track_lead_email_list_index_path
      find('h2').should have_content 'email address count: 1'
      find('.email_address').should have_content some_track_lead.email
    end
  end
end
