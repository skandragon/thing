require 'spec_helper'

describe InstructablesController do
  describe 'add button' do
    before :each do
      log_in
    end

    it 'renders' do
      create(:instructor_profile, user_id: current_user.id, class_limit: 5)
      visit user_instructables_path(current_user)
      find('.add-button').should have_content('Request a class')
    end

    it 'renders with a warning if at class limit' do
      create(:instructor_profile, user_id: current_user.id, class_limit: 0)
      visit user_instructables_path(current_user)
      page.should have_content('You are over your class session limit.')
    end
  end

  describe 'class limists' do
    before :each do
      log_in
    end

    it 'is at limit' do
      create(:instructor_profile, user_id: current_user.id, class_limit: 0)
      visit user_instructables_path(current_user)
      page.should have_content('You have requested 0 of your allowed 0 classes.')
    end

    it 'is not at limit' do
      create(:instructor_profile, user_id: current_user.id, class_limit: 5)
      visit user_instructables_path(current_user)
      page.should have_content('You have requested 0 of your allowed 5 classes.')
    end
  end

  describe 'manages' do
    before :each do
      log_in
      create(:instructor_profile, user_id: current_user.id, class_limit: 2)
    end

    describe 'creates' do
      it "with good data" do
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: "Foo Description"
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        page.should have_content('Foo Class Name')
      end

      it "does not with bad data" do
        visit new_user_instructable_path(current_user)
        click_on 'Create class'
        page.should have_content("can't be blank")
      end
    end

    describe 'updates' do
      it "with good data" do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: "Foo Description"
        fill_in 'Duration', with: '1'
        click_on 'Update class'
        page.should have_content('Foo Class Name')
      end

      it "does not with bad data" do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        fill_in 'Class title', with: ''
        click_on 'Update class'
        page.should have_content("can't be blank")
      end
    end
  end
end
