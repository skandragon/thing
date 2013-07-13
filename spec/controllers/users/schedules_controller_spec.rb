require 'spec_helper'

describe Users::SchedulesController do
  describe 'this-user' do
    describe '#show' do
      before :each do
        log_in
      end

      let (:user) { create(:user) }

      it 'redirects to #new when current_user has no profile' do
        visit user_schedule_path(current_user)
        current_path.should == edit_user_schedule_path(current_user)
      end

      it 'redirects to / with notice when some other user has no profile' do
        visit user_schedule_path(user)
        current_path.should == root_path
        page.should have_content 'No such schedule'
      end

      it 'redirects to / for invalid users' do
        visit user_schedule_path(0)
        current_path.should == root_path
        page.should have_content 'No such schedule'
      end
    end

    describe '#edit' do
      before :each do
        log_in
      end

      it 'creates new schedule on initial edit' do
        visit edit_user_schedule_path(current_user)
        current_user.schedule.should_not be_nil
      end

      it 'shows public checkbox' do
        visit edit_user_schedule_path(current_user)
        page.should have_field 'Publish publicly?'
      end

      it 'publishes when initially unchecked', js: true do
        visit edit_user_schedule_path(current_user)
        find('#options_publish').click
        sleep(0.5)
        current_user.reload
        current_user.schedule.published.should be_true
      end

      it 'unpublishes when initially checked', js: true do
        current_user.create_schedule(published: true)
        visit edit_user_schedule_path(current_user)
        find('#options_publish').click
        sleep(0.5)
        current_user.reload
        current_user.schedule.published.should be_false
      end
    end
  end
end