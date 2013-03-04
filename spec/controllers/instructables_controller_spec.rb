require 'spec_helper'

describe InstructablesController do
  describe 'requires login' do
    it "redirects" do
      user = create(:user)
      instructable = create(:instructable, user_id: user.id)
      visit user_instructables_path(user)
      page.should have_content 'You must log in.'
    end
  end

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

  describe 'class limits' do
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
        page.should have_content('Class created.')
      end

      it "does not with bad data" do
        visit new_user_instructable_path(current_user)
        click_on 'Create class'
        page.should have_content("can't be blank")
      end

      it "has one submit button" do
        visit new_user_instructable_path(current_user)
        all('.submit-button').count.should == 1
      end

      it "sends email to the user" do
        ActionMailer::Base.deliveries.clear
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: "Foo Description"
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        page.should have_content('Class created.')
        ActionMailer::Base.deliveries.count.should == 1
      end

      it "sends email to the admin" do
        ActionMailer::Base.deliveries.clear
        admin_user = create(:user, admin: true)
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: "Foo Description"
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        page.should have_content('Class created.')
        ActionMailer::Base.deliveries.count.should == 2
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
        page.should have_content('Class updated.')
      end

      it "does not with bad data" do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        fill_in 'Class title', with: ''
        click_on 'Update class'
        page.should have_content("can't be blank")
      end

      it "has one submit button" do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        all('.submit-button').count.should == 1
      end
    end

    describe "destroys", js: true do
      it "as owner" do
        instructable = create(:instructable, user_id: current_user.id)
        visit user_instructables_path(current_user)
        find('td.delete_clicky .btn').should have_content 'Delete'
        find('td.delete_clicky .btn').click
        page.should have_content "Are you sure you want to delete"
        click_on "Yes, I'm positively certain."
        page.should have_content("Class deleted.")
      end
    end
  end

  describe "as coordinator" do
    before :each do
      log_in tracks: ["Middle Eastern"]
      @other_user = create(:user)
      create(:instructor_profile, user_id: @other_user.id)
      @other_instructable = create(:instructable, user_id: @other_user.id, track: "Middle Eastern")
    end

    it "shows additional fields" do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      page.should have_selector '#instructable_approved'
    end

    it "has two submit buttons" do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      all('.submit-button').count.should == 2
    end

    it "allows :approved" do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_approved').select 'Yes'
      first('.submit-button').click
      page.should have_content 'Class updated.'
    end
  end

  describe "as admin" do
    before :each do
      log_in admin: true
      @other_user = create(:user)
      create(:instructor_profile, user_id: @other_user.id)
      @other_instructable = create(:instructable, user_id: @other_user.id, track: "Middle Eastern")
    end

    it "shows additional fields" do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      page.should have_selector '#instructable_track'
      page.should have_selector '#instructable_approved'
    end

    it "has two submit buttons" do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      all('.submit-button').count.should == 2
    end

    it "allows :track" do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_track').select 'Performing Arts'
      first('.submit-button').click
      page.should have_content 'Class updated.'
    end
  end
end
