require 'rails_helper'

describe InstructorProfilesController do
  it 'updates' do
    log_in instructor: true

    visit edit_user_instructor_profile_path(current_user)
    fill_in 'SCA name', with: 'Fred the Butcher'
    fill_in 'Legal name', with: 'Fred Baker'
    find('#user_phone_number').set '+1 405.555.1212'
    click_button 'Update profile'
    current_user.reload
    current_user.sca_name.should == 'Fred the Butcher'
  end

  it 'does not update with errors' do
    log_in instructor: true
    visit edit_user_instructor_profile_path(current_user)
    original_name = current_user.sca_name
    fill_in 'SCA name', with: ''
    fill_in 'Legal name', with: 'Fred Baker'
    find('#user_phone_number').set '+1 405.555.1212'
    click_button 'Update profile'
    current_user.reload
    current_user.sca_name.should == original_name
  end

  it 'creates' do
    log_in
    visit new_user_instructor_profile_path(current_user)
    fill_in 'SCA name', with: 'Fred the Butcher'
    fill_in 'Legal name', with: 'Fred Baker'
    find('#user_phone_number').set '+1 405.555.1212'
    select 'Ansteorra', from: 'SCA kingdom'
    click_button 'Create profile'
    page.should have_content 'Instructor profile created.'
    current_user.reload
    current_user.sca_name.should == 'Fred the Butcher'
    current_user.should be_instructor
  end

  it 'creates with title' do
    log_in
    visit new_user_instructor_profile_path(current_user)
    fill_in 'SCA name', with: 'Fred the Butcher'
    fill_in 'Legal name', with: 'Fred Baker'
    find('#user_phone_number').set '+1 405.555.1212'
    select 'Ansteorra', from: 'SCA kingdom'
    select 'Duchess', from: 'SCA title'
    click_button 'Create profile'
    page.should have_content 'Instructor profile created.'
    current_user.reload
    current_user.sca_name.should == 'Fred the Butcher'
    current_user.should be_instructor
  end


  it 'does not create on error' do
    log_in
    visit new_user_instructor_profile_path(current_user)
    fill_in 'SCA name', with: ''
    fill_in 'Legal name', with: 'Fred Baker'
    find('#user_phone_number').set '+1 405.555.1212'
    select 'Ansteorra', from: 'SCA kingdom'
    click_button 'Create profile'
    page.should_not have_content 'Instructor profile created.'
    current_user.should_not be_instructor
  end

  describe 'hides contact methods', js: true do
    describe 'on page load' do
      it 'shows if no_contact is false' do
        log_in instructor: true, no_contact: false
        visit edit_user_instructor_profile_path(current_user)
        page.should have_content 'Alternate Email'
      end

      it 'hides if no_contact is true' do
        log_in instructor: true, no_contact: true
        visit edit_user_instructor_profile_path(current_user)
        page.should_not have_content 'Alternate Email'
      end
    end

    describe 'on click' do
      it 'shows if initially hiden' do
        log_in instructor: true, no_contact: true
        visit edit_user_instructor_profile_path(current_user)
        page.should_not have_content 'Alternate Email'
        uncheck 'No contact'
        page.should have_content 'Alternate Email'
      end

      xit 'hides if initiailly shown' do
        log_in instructor: true, no_contact: false
        visit edit_user_instructor_profile_path(current_user)
        page.should have_content 'Alternate Email'
        #page.driver.render('/tmp/file1.png', :full => true)
        check 'No contact'
        #page.driver.render('/tmp/file2.png', :full => true)
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
    log_in instructor: true
    visit '/'
    page.should have_content 'Update instructor profile'
  end
end
