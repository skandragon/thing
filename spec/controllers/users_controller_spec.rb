require 'spec_helper'

describe UsersController do
  describe 'instructor status' do
    it 'displays "You are not an instructor" for normal users' do
      log_in
      visit user_path(current_user)
      page.should have_content 'You are not registered as an instructor.'
    end

    it 'displays "You are an instructor" for instructors' do
      log_in
      create(:instructor_profile, user_id: current_user.id, class_limit: 99)
      visit user_path(current_user)
      page.should have_content 'You are registered as an instructor.'
    end
  end

  it 'displays number of classes allowed for instructors' do
    log_in
    create(:instructor_profile, user_id: current_user.id, class_limit: 99)
    visit user_path(current_user)
    page.should have_content 'You may teach up to 99 classes.'
  end
end
