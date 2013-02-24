require 'spec_helper'

describe Admin::UsersController do
  it "requires admin" do
    visit admin_users_path
    page.should have_content('Not authorized')
  end

  it "renders user's name, email, and tract" do
    log_in admin: true, name: 'Fred', coordinator_tract: Instructable::TRACTS.keys.first
    visit admin_users_path
    find('.admin').should have_content('Yes')
    find('.display_name').should have_content('Fred')
    find('.display_name').should have_content current_user.email
    find('.coordinator_tract').should have_content current_user.coordinator_tract
  end

  it "renders 'no tract' if the user has no tract" do
    log_in admin: true, name: 'Fred'
    visit admin_users_path
    find('.coordinator_tract').should have_content '-'
  end
end
