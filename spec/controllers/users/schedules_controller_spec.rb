require 'rails_helper'

describe Users::SchedulesController, type: :controller do
  describe 'no-user' do
    describe '#show' do
      let (:user) {
        # noinspection RubyQuotedStringsInspection
        create(:user, sca_title: "lord", sca_name: 'Griffin')
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
        expect(page).to have_content 'Custom Schedule for Lord Griffin'
      end

      it 'disallows unpublished schedules' do
        create(:schedule, user_id: user.id, instructables: [instructable.id], published: false)

        visit user_schedule_path(user)
        expect(page).to have_content 'Not authorized.'
      end

      it 'accepts access token' do
        create(:schedule, user_id: user.id, instructables: [instructable.id], published: false)

        visit user_schedule_path(user.access_token)
        expect(page).to have_content 'Custom Schedule for Lord Griffin'
      end

      it 'accepts access token' do
        visit user_schedule_path('flarg')
        expect(page).to have_content 'Not authorized.'
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
        expect(current_path).to eql edit_user_schedule_path(current_user)
      end

      it 'redirects to #new when current_user has no schedule, format csv' do
        visit user_schedule_path(current_user, format: :csv)
        expect(current_path).to eql edit_user_schedule_path(current_user)
      end

      it 'redirects to / with notice when some other user has no schedule' do
        visit user_schedule_path(user)
        expect(current_path).to eql root_path
        expect(page).to have_content 'No such schedule'
      end

      it 'redirects to / for invalid users' do
        visit user_schedule_path(0)
        expect(current_path).to eql root_path
        expect(page).to have_content 'Not authorized.'
      end
    end

    describe '#edit' do
      before :each do
        log_in
      end

      def make_instructables
        @instructable1 = create(:scheduled_instructable, user_id: current_user.id, topic: 'Martial', name: 'InstructableOne')
        @instructable2 = create(:scheduled_instructable, user_id: current_user.id, culture: 'Middle Eastern', name: 'InstructableTwo')
        @instructable3 = create(:scheduled_instructable, user_id: current_user.id, name: 'ClassThree')
      end

      it 'creates new schedule on initial edit' do
        visit edit_user_schedule_path(current_user)
        expect(current_user.schedule).to_not be_nil
      end

      it 'clear filter button works' do
        make_instructables
        visit edit_user_schedule_path(current_user)
        fill_in 'search', with: 'XxxXXxxxXxxXXXXxxX'
        click_on 'Filter'
        expect(page).to_not have_content @instructable1.name
        expect(page).to_not have_content @instructable2.name
        expect(page).to_not have_content @instructable3.name
        click_on 'Clear'
        expect(page).to have_content @instructable1.name
        expect(page).to have_content @instructable2.name
        expect(page).to have_content @instructable3.name
      end

      it 'searches by partial title' do
        make_instructables
        visit edit_user_schedule_path(current_user)
        fill_in 'search', with: 'Instructable'
        click_on 'Filter'
        expect(page).to have_content @instructable1.name
        expect(page).to have_content @instructable2.name
        expect(page).to_not have_content @instructable3.name
      end

      it 'searches by topic' do
        make_instructables
        visit edit_user_schedule_path(current_user)
        select 'Martial', from: 'topic'
        click_on 'Filter'
        expect(page).to have_content @instructable1.name
        expect(page).to_not have_content @instructable2.name
        expect(page).to_not have_content @instructable3.name
      end

      it 'searches by culture' do
        make_instructables
        visit edit_user_schedule_path(current_user)
        select 'Middle Eastern', from: 'culture'
        click_on 'Filter'
        expect(page).to_not have_content @instructable1.name
        expect(page).to have_content @instructable2.name
        expect(page).to_not have_content @instructable3.name
      end

      it 'shows public checkbox' do
        visit edit_user_schedule_path(current_user)
        expect(page).to have_field 'Publish publicly?'
      end

      it 'publishes when initially unchecked', js: true do
        visit edit_user_schedule_path(current_user)
        find('#options_publish').click
        current_user.reload
        expect(current_user.schedule.published).to be_truthy
      end

      it 'unpublishes when initially checked', js: true do
        current_user.create_schedule(published: true)
        visit edit_user_schedule_path(current_user)
        find('#options_publish').click
        current_user.reload
        expect(current_user.schedule.published).to be_falsey
      end

      it 'add and remove buttons work', js: true do
        make_instructables
        button1 = "#button-#{@instructable1.id}"
        button2 = "#button-#{@instructable2.id}"

        visit edit_user_schedule_path(current_user)

        expect(find(button1)).to have_text 'Add'
        find(button1).click
        expect(find(button1)).to have_text 'Remove'
        current_user.reload
        expect(current_user.schedule.instructables).to eql [@instructable1.id]

        expect(find(button2)).to have_text 'Add'
        find(button2).click
        expect(find(button2)).to have_text 'Remove'
        current_user.reload
        expect(current_user.schedule.instructables).to eql [@instructable1.id, @instructable2.id]

        find(button1).click
        current_user.reload
        expect(current_user.schedule.instructables).to eql [@instructable2.id]
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
        expect(page.response_headers['Content-Type']).to eql 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end

      it 'renders pdf brief' do
        visit user_schedule_path(current_user, brief: true, format: :pdf, uncached_for_tests: true)
        expect(page.response_headers['Content-Type']).to eql 'application/pdf'
        expect(page.body).to_not be_blank
        expect(page.body[0..3]).to eql '%PDF'
      end

      it 'renders pdf long' do
        visit user_schedule_path(current_user, format: :pdf, uncached_for_tests: true)
        expect(page.response_headers['Content-Type']).to eql 'application/pdf'
        expect(page.body).to_not be_blank
        expect(page.body[0..3]).to eql '%PDF'
      end

      it 'renders csv' do
        visit user_schedule_path(current_user, format: :csv, uncached_for_tests: true)
        expect(page.response_headers['Content-Type']).to eql 'text/csv'
        expect(page).to have_content @instructable.name
      end

      it 'renders ics' do
        visit user_schedule_path(current_user, format: :ics, uncached_for_tests: true)
        expect(page.response_headers['Content-Type']).to eql 'text/calendar'
        expect(page.body).to_not be_blank
        expect(page.body[0..14]).to eql 'BEGIN:VCALENDAR'
        expect(page.body).to match @instructable.name
      end
    end
  end
end
