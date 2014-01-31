require 'spec_helper'

describe Users::SchedulesController do
  describe 'no-user' do
    describe '#show' do
      let (:user) {
        create(:user, sca_title: "lord", sca_name: "Griffin")
      }

      let (:instructable) {
        instructable = create(:scheduled_instructable, user_id: user)
        instructable.user_id = user.id
        instructable.save!
        instructable
      }

      it 'allows published schedules' do
        create(:schedule, user_id: user.id, instructables: [instructable.id], published: true)

        visit user_schedule_path(user)
        page.should have_content 'Custom Schedule for Lord Griffin'
      end

      it 'disallows unpublished schedules' do
        create(:schedule, user_id: user.id, instructables: [instructable.id], published: false)

        visit user_schedule_path(user)
        page.should have_content 'Not authorized.'
      end

      it 'accepts access token' do
        create(:schedule, user_id: user.id, instructables: [instructable.id], published: false)

        visit user_schedule_path(user.access_token)
        page.should have_content 'Custom Schedule for Lord Griffin'
      end

      it 'accepts access token' do
        visit user_schedule_path('flarg')
        page.should have_content 'Not authorized.'
      end
    end
  end

  describe 'this-user' do
    describe '#show' do
      before :each do
        log_in
      end

      let (:user) { create(:user) }

      it 'redirects to #new when current_user has no schedule' do
        visit user_schedule_path(current_user)
        current_path.should == edit_user_schedule_path(current_user)
      end

      it 'redirects to #new when current_user has no schedule, format csv' do
        visit user_schedule_path(current_user, format: :csv)
        current_path.should == edit_user_schedule_path(current_user)
      end

      it 'redirects to / with notice when some other user has no schedule' do
        visit user_schedule_path(user)
        current_path.should == root_path
        page.should have_content 'No such schedule'
      end

      it 'redirects to / for invalid users' do
        visit user_schedule_path(0)
        current_path.should == root_path
        page.should have_content 'Not authorized.'
      end
    end

    describe '#edit' do
      before :each do
        log_in
      end

      def make_instructables
        @instructable1 = create(:scheduled_instructable, user_id: current_user.id)
        @instructable2 = create(:scheduled_instructable, user_id: current_user.id)
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

      it 'add and remove buttons work', js: true do
        make_instructables
        button1 = "#button-#{@instructable1.id}"
        button2 = "#button-#{@instructable2.id}"

        visit edit_user_schedule_path(current_user)

        find(button1).should have_text 'Add'
        find(button1).click
        sleep(0.5)
        find(button1).should have_text 'Remove'
        current_user.reload
        current_user.schedule.instructables.should == [@instructable1.id]

        find(button2).should have_text 'Add'
        find(button2).click
        sleep(0.5)
        find(button2).should have_text 'Remove'
        current_user.reload
        current_user.schedule.instructables.should == [@instructable1.id, @instructable2.id]

        find(button1).click
        sleep(0.5)
        current_user.reload
        current_user.schedule.instructables.should == [@instructable2.id]
      end
    end

    describe '#show with formats' do
      before :each do
        log_in

        @instructable = create(:scheduled_instructable, user_id: current_user.id)
        @instructable.user_id = current_user.id
        @instructable.save!

        create(:schedule, user_id: current_user.id, instructables: [@instructable.id], published: false)
      end

      it 'renders xlsx' do
        visit user_schedule_path(current_user, format: :xlsx, uncached_for_tests: true)
        page.response_headers['Content-Type'].should == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end

      it 'renders pdf brief' do
        visit user_schedule_path(current_user, brief: true, format: :pdf, uncached_for_tests: true)
        page.response_headers['Content-Type'].should == 'application/pdf'
        page.body.should_not be_blank
        page.body[0..3].should == '%PDF'
      end

      it 'renders pdf long' do
        visit user_schedule_path(current_user, format: :pdf, uncached_for_tests: true)
        page.response_headers['Content-Type'].should == 'application/pdf'
        page.body.should_not be_blank
        page.body[0..3].should == '%PDF'
      end

      it 'renders csv' do
        visit user_schedule_path(current_user, format: :csv, uncached_for_tests: true)
        page.response_headers['Content-Type'].should == 'text/csv'
        page.should have_content @instructable.name
      end

      it 'renders ics' do
        visit user_schedule_path(current_user, format: :ics, uncached_for_tests: true)
        page.response_headers['Content-Type'].should == 'text/calendar'
        page.body.should_not be_blank
        page.body[0..14].should == 'BEGIN:VCALENDAR'
        page.body.should match @instructable.name
      end
    end
  end
end
