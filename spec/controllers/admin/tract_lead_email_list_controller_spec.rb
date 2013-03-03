require 'spec_helper'

describe Admin::TractLeadEmailListController do
  it 'requires admin' do
    visit admin_tract_lead_email_list_index_path
    page.should have_content('Not authorized')
  end

  describe 'listing' do
    it 'renders only tract lead email addresses' do
      some_tract_lead = create(:user)
      create(:instructor_profile, user_id: some_tract_lead.id)
      some_tract_lead.coordinator_tract = 'Middle Eastern'
      some_tract_lead.save
      2.times do
        create(:user)
        create(:instructor_profile, user_id: create(:user).id)
      end
      log_in admin: true
      visit admin_tract_lead_email_list_index_path
      find('h2').should have_content 'email address count: 1'
      find('.email_address').should have_content some_tract_lead.email
    end
  end
end
