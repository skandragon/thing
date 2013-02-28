require 'spec_helper'

describe Admin::InstructorEmailListController do
  it "requires admin" do
    visit admin_instructor_email_list_index_path
    page.should have_content('Not authorized')
  end

  describe "listing" do
    it "renders only instructor email addresses" do
      some_user = create(:user)
      some_instructor = create(:user)
      profile =create(:instructor_profile, user_id: some_instructor.id)
      log_in admin: true
      visit admin_instructor_email_list_index_path
      find('h2').should have_content 'email address count: 1'
      find('.email_address').should have_content some_instructor.email
    end
  end
end
