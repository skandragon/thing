require 'rails_helper'

describe Admin::InstructorEmailListController, type: :controller do
  it 'requires admin' do
    visit admin_instructor_email_list_index_path
    expect(page).to have_content('Not authorized')
  end

  describe 'listing' do
    it 'renders only instructor email addresses' do
      create(:user)
      some_instructor = create(:instructor)
      log_in admin: true
      visit admin_instructor_email_list_index_path
      expect(find('h2')).to have_content 'email address count: 1'
      expect(find('.email_address')).to have_content some_instructor.email
    end
  end
end
