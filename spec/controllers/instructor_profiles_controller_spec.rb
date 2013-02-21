require 'spec_helper'

describe InstructorProfilesController do
  it 'updates' do
    log_in
    profile = create(:instructor_profile, user_id: current_user.id)
    visit edit_user_instructor_profile_path(current_user)
    fill_in 'SCA name', with: 'Fred the Butcher'
    fill_in 'Legal name', with: 'Fred Baker'
    find('#instructor_profile_phone_number').set '+1 405.555.1212'
    click_button 'Update profile'
    profile.reload
    profile.sca_name.should == 'Fred the Butcher'
  end

  it 'does not update with errors' do
    log_in
    profile = create(:instructor_profile, user_id: current_user.id)
    visit edit_user_instructor_profile_path(current_user)
    original_name = profile.sca_name
    fill_in 'SCA name', with: ''
    fill_in 'Legal name', with: 'Fred Baker'
    find('#instructor_profile_phone_number').set '+1 405.555.1212'
    click_button 'Update profile'
    profile.reload
    profile.sca_name.should == original_name
  end

  it 'creates' do
    log_in
    visit new_user_instructor_profile_path(current_user)
    fill_in 'SCA name', with: 'Fred the Butcher'
    fill_in 'Legal name', with: 'Fred Baker'
    find('#instructor_profile_phone_number').set '+1 405.555.1212'
    select 'Ansteorra', from: 'SCA kingdom'
    click_button 'Create profile'
    page.should have_content 'Instructor profile created.'
    current_user.reload
    profile = current_user.instructor_profile
    profile.sca_name.should == 'Fred the Butcher'
    current_user.should be_instructor
  end

  it 'does not create on error' do
    log_in
    visit new_user_instructor_profile_path(current_user)
    fill_in 'SCA name', with: ''
    fill_in 'Legal name', with: 'Fred Baker'
    find('#instructor_profile_phone_number').set '+1 405.555.1212'
    select 'Ansteorra', from: 'SCA kingdom'
    click_button 'Create profile'
    page.should_not have_content 'Instructor profile created.'
    current_user.should_not be_instructor
  end

  describe "redirects on strangeness" do
    it "rediects from new to edit if profile exists" do
      log_in
      create(:instructor_profile, user_id: current_user.id)
      visit new_user_instructor_profile_path(current_user)
      page.current_path.should == edit_user_instructor_profile_path(current_user)
    end

    it "rediects from edit to new if no profile exists" do
      log_in
      visit edit_user_instructor_profile_path(current_user)
      page.current_path.should == new_user_instructor_profile_path(current_user)
    end
  end

  describe "hides contact methods", js: true do
    describe "on page load" do
      before :each do
        log_in
      end

      it "shows if no_contact is false" do
        pending "broken js"
        create(:instructor_profile, user_id: current_user.id, no_contact: false)
        visit edit_user_instructor_profile_path(current_user)

        page.should have_content 'Alternate Email'
      end

      it "hides if no_contact is true" do
        pending "broken js"
        create(:instructor_profile, user_id: current_user.id, no_contact: true)
        visit edit_user_instructor_profile_path(current_user)

        page.should_not have_content 'Alternate Email'
      end
    end

    describe "on click" do

      before :each do
        log_in
      end

      it "shows if initially hiden" do
        pending "broken js"
        create(:instructor_profile, user_id: current_user.id, no_contact: true)
        visit edit_user_instructor_profile_path(current_user)
        page.should_not have_content 'Alternate Email'
        uncheck "No contact"
        page.should have_content 'Alternate Email'
      end

      it "hides if initiailly shown" do
        pending 'broken, but screenshots verify it works...'
        create(:instructor_profile, user_id: current_user.id, no_contact: false)
        visit edit_user_instructor_profile_path(current_user)
        page.should have_content 'Alternate Email'
#        page.driver.render('/tmp/file1.png', :full => true)
        check "No contact"
#        page.driver.render('/tmp/file2.png', :full => true)
        page.should_not have_content 'Alternate Email'
      end
    end
  end

  it 'requires all profile fields' do
    log_in
    visit new_user_instructor_profile_path(current_user)
    click_button 'Create profile'
    page.should_not have_content 'Instructor profile created.'
  end

  it 'displays the option to become an instructor if not an instructor' do
    log_in
    page.should have_content 'Request to be an instructor'
  end

  it 'displays the option to update profile if an instructor' do
    log_in
    create(:instructor_profile, user_id: current_user.id)
    visit '/'
    page.should have_content 'Update instructor profile'
  end
end
