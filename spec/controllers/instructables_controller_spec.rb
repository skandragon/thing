require 'rails_helper'

describe InstructablesController, type: :controller do
  describe 'requires login' do
    it 'redirects' do
      user = create(:instructor)
      create(:instructable, user_id: user.id)
      visit user_instructables_path(user)
      expect(page).to have_content 'You must log in.'
    end
  end

  describe 'add button' do
    it 'renders' do
      log_in instructor: true
      visit user_instructables_path(current_user)
      expect(find('.add-button')).to have_content('Request a class')
    end

    it 'renders with a warning if at class limit' do
      log_in(instructor: true, class_limit: 0)
      visit user_instructables_path(current_user)
      expect(page).to have_content('You are at or over your class session limit.')
    end
  end

  describe 'class limits' do
    it 'is at limit' do
      log_in(instructor: true, class_limit: 0)
      visit user_instructables_path(current_user)
      expect(page).to have_content('You have requested 0 of your allowed 0 classes.')
    end

    it 'is not at limit' do
      log_in(instructor: true, class_limit: 5)
      visit user_instructables_path(current_user)
      expect(page).to have_content('You have requested 0 of your allowed 5 classes.')
    end
  end

  describe 'previous class' do
    before :each do
      log_in instructor: true, class_limit: 2
      @class = create(:instructable, user_id: current_user.id, track: 'Middle Eastern',
             topic: 'History', name: 'MEHistoryScheduledApproved',
             approved: true, year: 1899)
    end

    it 'should offer to copy from previous year class' do
      visit user_instructables_path(current_user)
      expect(page).to have_content 'MEHistoryScheduledApproved'
      expect(page).to have_content '1899'
    end

    it 'should clone for new entry' do
      visit user_instructables_path(current_user)
      click_on 'Request for This Year'
      expect(page).to have_content @class.description_book
    end
  end

  describe 'manages' do
    before :each do
      log_in(instructor: true, class_limit: 2)
    end

    describe 'creates' do
      it 'with good data' do
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: 'Foo Description'
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        expect(page).to have_content('Class created.')
        expect(Changelog.count).to equal 1
      end

      it 'does not with bad data' do
        visit new_user_instructable_path(current_user)
        click_on 'Create class'
        expect(page).to have_content("can't be blank")
        expect(Changelog.count).to equal 0
      end

      it 'has one submit button' do
        visit new_user_instructable_path(current_user)
        expect(all('.submit-button').count).to equal 1
      end

      it 'sends email to the user' do
        ActionMailer::Base.deliveries.clear
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: 'Foo Description'
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        expect(page).to have_content('Class created.')
        expect(ActionMailer::Base.deliveries.count).to equal 1
      end

      it 'displays a flash for failed email' do
        ActionMailer::Base.deliveries.clear
        InstructablesMailer.any_instance.should_receive(:on_create).and_throw(Net::SMTPFatalError)
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: 'Foo Description'
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        expect(page).to have_content('Class created.')
        expect(page).to have_content 'Email could not be delivered to your account'
        expect(ActionMailer::Base.deliveries.count).to equal 0
      end

      it 'displays a flash for failed admin email' do
        ActionMailer::Base.deliveries.clear
        InstructablesMailer.any_instance.should_receive(:on_create).and_throw(Net::SMTPFatalError)
        create(:user, admin: true)
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: 'Foo Description'
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        expect(page).to have_content('Class created.')
        expect(page).to have_content 'Email could not be sent to one or more track coordinators.'
        expect(ActionMailer::Base.deliveries.count).to equal 0
      end

      it 'sends email to the admin' do
        ActionMailer::Base.deliveries.clear
        create(:user, admin: true)
        visit new_user_instructable_path(current_user)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: 'Foo Description'
        fill_in 'Duration', with: '1'
        select 'History', from: 'Topic'
        click_on 'Create class'
        expect(page).to have_content('Class created.')
        expect(ActionMailer::Base.deliveries.count).to equal 2
      end
    end

    describe 'updates' do
      it 'with good data' do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        fill_in 'Class title', with: 'Foo Class Name'
        fill_in 'Description (book)', with: 'Foo Description'
        fill_in 'Duration', with: '1'
        click_on 'Update class'
        expect(page).to have_content('Class updated.')
        instructable.reload
        expect(instructable.name).to equal 'Foo Class Name'
        expect(instructable.description_book).to equal 'Foo Description'
        expect(Changelog.count).to equal 1
      end

      it 'does not with bad data' do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        fill_in 'Class title', with: ''
        click_on 'Update class'
        expect(page).to have_content("can't be blank")
        expect(Changelog.count).to equal 0
      end

      it 'has one submit button' do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        expect(all('.submit-button').count).to equal 1
      end

      # camp details select

      it 'shows camp data if changed to a camp', js: true do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to_not have_content('Camp or Booth Location')
        select 'Private Camp', from: 'Private camp or merchant?'
        expect(page).to have_content('Camp or Booth Location')
      end

      it 'shows camp data if initially in a camp', js: true do
        instructable = create(:instructable, user_id: current_user.id, location_type: 'private-camp', camp_name: 'foo', camp_reason: 'foo')
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to have_content('Camp or Booth Location')
      end

      it 'hides camp data if changed to not in a camp', js: true do
        instructable = create(:instructable, user_id: current_user.id, location_type: 'private-camp', camp_name: 'foo', camp_reason: 'foo')
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to have_content('Camp or Booth Location')
        select 'No', from: 'Private camp or merchant?'
        expect(page).to_not have_content('Camp or Booth Location')
      end

      # adult clickly

      it 'shows adult only reason if checked', js: true do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to_not have_content('Adult reason')
        check 'Adult only'
        expect(page).to have_content('Adult reason')
      end

      it 'shows adult only reason if initally checked', js: true do
        instructable = create(:instructable, user_id: current_user.id, adult_only: true, adult_reason: 'foo')
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to have_content('Adult reason')
      end

      it 'hides adult only reason if unchecked', js: true do
        instructable = create(:instructable, user_id: current_user.id, adult_only: true, adult_reason: 'foo')
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to have_content('Adult reason')
        uncheck '#instructable_adult_only'
        expect(page).to_not have_content('Adult reason')
      end

      # heat source clicky

      it 'shows heat source description if checked', js: true do
        instructable = create(:instructable, user_id: current_user.id)
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to_not have_content('Heat source description')
        check 'Heat source'
        expect(page).to have_content('Heat source description')
      end

      it 'shows heat source description if initally checked', js: true do
        instructable = create(:instructable, user_id: current_user.id, heat_source: true, heat_source_description: 'flarg')
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to have_content('Heat source description')
      end

      it 'hides heat source description if unchecked', js: true do
        instructable = create(:instructable, user_id: current_user.id, heat_source: true, heat_source_description: 'flarg')
        visit edit_user_instructable_path(current_user, instructable)
        expect(page).to have_content('Heat source description')
        uncheck 'Heat source'
        expect(page).to_not have_content('Heat source description')
      end
    end

    describe 'destroys', js: true do
      it 'as owner' do
        create(:instructable, user_id: current_user.id)
        visit user_instructables_path(current_user)
        expect(find('td.delete_clicky .btn')).to have_content 'Delete'
        find('td.delete_clicky .btn').click
        expect(page).to have_content 'Are you sure you want to delete'
        click_on "Yes, I'm positively certain."
        expect(page).to have_content('Class deleted.')
      end
    end
  end

  describe 'as coordinator' do
    before :each do
      log_in tracks: ['Middle Eastern']
      @other_user = create(:instructor)
      @other_instructable = create(:instructable, user_id: @other_user.id,
                                   track: 'Middle Eastern', repeat_count: 3)
      @camp_instructable = create(:instructable, user_id: @other_user.id,
                                  track: 'Middle Eastern', repeat_count: 3,
                                  location_type: 'private-camp',
                                  camp_name: 'flarg', camp_reason: 'flarg',
                                  camp_address: 'N06')
    end

    it 'shows additional fields' do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      expect(page).to have_selector '#instructable_approved'
    end

    it 'has two submit buttons' do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      expect(all('.submit-button').count).to equal 2
    end

    it 'allows :approved' do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_approved').select 'Yes'
      first('.submit-button').click
      expect(page).to have_content 'Class updated.'
      @other_instructable.reload
      expect(@other_instructable.approved).to be_truthy
      expect(Changelog.count).to equal 1
    end

    it 'shows repeat_count sessions' do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      expect(page).to have_content "#{@other_instructable.repeat_count} sessions requested."
      @other_instructable.repeat_count.times do |i|
        expect(all("#instructable_instances_attributes_#{i}_start_time").count).to equal 1
        expect(all("#instructable_instances_attributes_#{i}_location").count).to equal 1
      end
    end

    it 'shows only start_time fields for in-camp classes' do
      visit edit_user_instructable_path(@other_user, @camp_instructable)
      expect(page).to have_content "#{@camp_instructable.repeat_count} sessions requested."
      @camp_instructable.repeat_count.times do |i|
        expect(all("#instructable_instances_attributes_#{i}_start_time").count).to equal 1
        expect(all("#instructable_instances_attributes_#{i}_location").count).to equal 0
      end
    end

    it 'shows start_time if populated, ordered by start time' do
      @camp_instructable.instances.create!(start_time: get_date(1))
      @camp_instructable.instances.create!(start_time: get_date(0))
      @camp_instructable.instances.create!(start_time: get_date(2))
      visit edit_user_instructable_path(@other_user, @camp_instructable)
      expect(page).to have_content "#{@camp_instructable.repeat_count} sessions requested."
      one = find('#instructable_instances_attributes_0_start_time').value
      two = find('#instructable_instances_attributes_1_start_time').value
      three = find('#instructable_instances_attributes_2_start_time').value
      expect([one, two, three].sort).to match_array([one, two, three])
    end

    it 'warns, and marks start time and location as disabled if overridden' do
      @other_instructable.instances.create!(start_time: get_date(0), location: 'A&S 6', override_location: true)
      visit edit_user_instructable_path(@other_user, @other_instructable)
      expect(page).to have_content 'overridden by an administrator, and cannot be changed.'
      expect(find('#instructable_instances_attributes_0_start_time')['disabled']).to eql 'disabled'
      expect(find('#instructable_instances_attributes_0_location')['disabled']).to eql 'disabled'
    end

    it 'allows update of requested times with error for other field' do
      @other_instructable.save!
      visit edit_user_instructable_path(@other_user, @other_instructable)
      fill_in 'Class title', with: ''
      find(:css, '#instructable_requested_days_2016-08-01').set(true)
      first('.submit-button').click
      expect(page).to have_content "can't be blank"
    end
  end

  describe 'as admin' do
    before :each do
      log_in admin: true
      @other_user = create(:instructor)
      @other_instructable = create(:instructable, user_id: @other_user.id, track: 'Middle Eastern')
    end

    it 'shows additional fields' do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      expect(page).to have_selector '#instructable_track'
      expect(page).to have_selector '#instructable_approved'
    end

    it 'has two submit buttons' do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      expect(all('.submit-button').count).to equal 2
    end

    it 'allows :track' do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_track').select 'Performing Arts and Music'
      first('.submit-button').click
      expect(page).to have_content 'Class updated.'
      @other_instructable.reload
      expect(@other_instructable.track).to equal 'Performing Arts and Music'
      expect(Changelog.count).to equal 1
    end

    it 'populates location based on track on load', js: true do
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_instances_attributes_0_location').select Instructable::TRACKS['Middle Eastern'].first
    end

    it 'populates location when track changes', js: true do
      @other_instructable.instances.create!(start_time: get_date(0))
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_track').select 'Performing Arts and Music'
      find('#instructable_instances_attributes_0_location').select Instructable::TRACKS['Performing Arts and Music'].first
    end

    it 'populates location for PU space when overridden on load', js: true do
      @other_instructable.instances.create!(start_time: get_date(0), location: 'A&S 6', override_location: true)
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_instances_attributes_0_location').select 'Battlefield'
    end

    it 'populates location for PU space when overridden checked', js: true do
      @other_instructable.instances.create!(start_time: get_date(0), location: 'A&S 6')
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_instances_attributes_0_override_location').set(true)
      find('#instructable_instances_attributes_0_location').select 'Battlefield'
    end

    it 'restores track location overridden unchecked', js: true do
      @other_instructable.instances.create!(start_time: get_date(0), location: 'A&S 6', override_location: true)
      visit edit_user_instructable_path(@other_user, @other_instructable)
      find('#instructable_instances_attributes_0_override_location').set(false)
      find('#instructable_instances_attributes_0_location').select Instructable::TRACKS['Middle Eastern'].first
    end
  end
end
