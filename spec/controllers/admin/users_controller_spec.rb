require 'spec_helper'

describe Admin::UsersController do
  it "requires admin" do
    visit admin_users_path
    page.should have_content('Not authorized')
  end

  it "renders a list" do
    log_in admin: true, name: "Fred"
    visit admin_users_path
    page.should have_content('Fred')
  end
end
