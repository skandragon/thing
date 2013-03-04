require 'spec_helper'

describe Admin::UsersController do
  it "requires admin" do
    visit admin_users_path
    page.should have_content('Not authorized')
  end

  describe "listing" do
    it "renders user's name, email, and track" do
      log_in admin: true, name: 'Fred', tracks: [Instructable::TRACKS.keys.first, Instructable::TRACKS.keys.last]
      visit admin_users_path
      find('.admin').should have_content('Yes')
      find('.display_name').should have_content('Fred')
      find('.display_name').should have_content current_user.email
      for track in current_user.tracks
        find('.tracks').should have_content track
      end
    end

    it "renders '-' if the user has no track" do
      log_in admin: true, name: 'Fred'
      visit admin_users_path
      find('.tracks').should have_content '-'
    end

    it "renders with more than a page full of users" do
      30.times do
        create(:user)
      end
      log_in admin: true
      visit admin_users_path
    end
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

    it "updates" do
      visit edit_admin_user_path(@other_user)
      page.should have_content @other_user.email
      fill_in 'Email address', with: 'example@example.com'
      click_on 'Update user'
      page.should have_content 'User updated.'
    end

    it "re-renders form on error" do
      visit edit_admin_user_path(@other_user)
      page.should have_content @other_user.email
      fill_in 'Email address', with: ''
      click_on 'Update user'
      page.should_not have_content 'User updated.'
    end
  end
end
