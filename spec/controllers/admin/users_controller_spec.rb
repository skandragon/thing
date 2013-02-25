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

  it "renders '-' if the user has no tract" do
    log_in admin: true, name: 'Fred'
    visit admin_users_path
    find('.coordinator_tract').should have_content '-'
  end

  describe "edit user" do
    before :each do
      log_in admin: true
      @other_user = create(:user)
      @link_id = "\#edit_user_#{@other_user.id}"
    end

    it "shows link" do
      visit admin_users_path
      find(@link_id).should have_content @other_user.email
    end

    it "link works" do
      visit admin_users_path
      click_on @other_user.display_name
      page.should have_content "Editing #{@other_user.display_name}"
    end
  end

  describe "edit" do
    before :each do
      log_in admin: true
      @other_user = create(:user)
    end

    it "renders" do
      visit edit_admin_user_path(@other_user)
      page.should have_content "Editing #{@other_user.display_name}"
    end
  end
end
