require 'rails_helper'

describe Proofreader::InstructablesController do
  def setup_data
    user = create(:user)
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Performing Arts and Music', name: 'MEMusicUnscheduledUnproofed')
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Dance', name: 'MEDanceUnscheduledProofed',
           proofread: true, proofread_by: [user, 123], is_proofreader: :no_really)
    i = create(:instructable, user_id: user.id, track: 'Middle Eastern',
               topic: 'History', name: 'MEHistoryScheduledProofed',
               proofread: true, proofread_by: [user, 123], is_proofreader: :no_really)
    i.instances.create(start_time: get_date(0), location: 'Foo')
    i = create(:instructable, user_id: user.id, track: 'Performing Arts and Music',
               topic: 'History', name: 'PAHistoryScheduledProofed',
               proofread: true, proofread_by: [user, 123], is_proofreader: :no_really)
    i.instances.create(start_time: get_date(1), location: 'Foo')
    create(:instructable, user_id: user.id, track: 'Archery',
           topic: 'Martial', name: 'ArcheryUnscheduledUnproofed')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Martial', name: 'TracklessArchery')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Performing Arts and Music', name: 'TracklessMusic')
  end

  it 'requires permission' do
    log_in proofreader: false
    visit proofreader_instructables_path
    page.should have_content 'Not authorized.'
  end

  describe 'index' do
    before :each do
      setup_data
      log_in proofreader: true
      visit proofreader_instructables_path
    end

    it 'renders as proofreader' do
      page.should have_button 'Filter'
      page.should have_content 'MEMusicUnscheduledUnproofed'
      page.should have_content 'MEDanceUnscheduledProofed'
      page.should have_content 'MEHistoryScheduledProofed'
      page.should have_content 'PAHistoryScheduledProofed'
    end

    it 'allows selection of track' do
      page.should have_select('track')
    end

    it 'filters based on track' do
      select 'Middle Eastern', from: 'track'
      click_on 'Filter'
      page.should have_content 'MEMusicUnscheduledUnproofed'
      page.should have_content 'MEDanceUnscheduledProofed'
      page.should have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on track of No Track' do
      select 'No Track', from: 'track'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnscheduledUnproofed'
      page.should_not have_content 'MEDanceUnscheduledProofed'
      page.should_not have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on proofread = 1' do
      select 'Proofread', from: 'proofread'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnproofed'
      page.should have_content 'MEDanceUnscheduledProofed'
      page.should have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on proofread = 0' do
      select 'Not Proofread', from: 'proofread'
      click_on 'Filter'
      page.should have_content 'MEMusicUnscheduledUnproofed'
      page.should_not have_content 'MEDanceUnscheduledProofed'
      page.should_not have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on topic' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      page.should_not have_content 'MEMusicUnscheduledUnproofed'
      page.should have_content 'MEDanceUnscheduledProofed'
      page.should_not have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on partial class name' do
      fill_in 'search', with: 'Unscheduled'
      click_on 'Filter'
      page.should have_content 'MEMusicUnscheduledUnproofed'
      page.should have_content 'MEDanceUnscheduledProofed'
      page.should_not have_content 'MEHistoryScheduledProofed'
    end

    it 'clears the form' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      click_on 'Clear'
      page.should have_content 'MEMusicUnscheduledUnproofed'
      page.should have_content 'MEDanceUnscheduledProofed'
      page.should have_content 'MEHistoryScheduledProofed'
    end
  end

  describe 'edit' do
    before :each do
      @random_user = create(:instructor)
      @random_instructable = create(:instructable, user_id: @random_user.id)
      log_in proofreader: true
      @random_proofread = create(:instructable, user_id: @random_user.id, proofread: true, proofread_by: [@random_user.id], is_proofreader: :no_really)
    end

    it 'renders edit form' do
      visit edit_proofreader_instructable_path(@random_instructable)
      find_field('Class title').value.should == @random_instructable.name.to_s
      find_field('Description (book)').value.should == @random_instructable.description_book.to_s
      find_field('Description (web)').value.should == @random_instructable.description_web.to_s
      find_field('Culture').value.should == @random_instructable.culture.to_s
      find_field('Topic').value.should == @random_instructable.topic.to_s
    end

    it 'submits, updates, marks proofread' do
      visit edit_proofreader_instructable_path(@random_proofread)
      fill_in 'Class title', with: 'Foo Class Name Here'
      click_on 'Save and Mark Proofread'
      @random_proofread.reload
      @random_proofread.name.should == 'Foo Class Name Here'
      @random_proofread.proofread.should_not be_true
      @random_proofread.proofread_by.should == [current_user.id]
      Changelog.count.should == 1
      cl = Changelog.first
      cl.changelog.should_not == {}
      cl.changelog.should have_key('name')
    end

    it 'marks proofread when really proofread' do
      @random_proofread.proofread_by.should_not include(current_user.id)
      visit edit_proofreader_instructable_path(@random_proofread)
      click_on 'Save and Mark Proofread'
      @random_proofread.reload
      @random_proofread.proofread_by.should include(current_user.id)
      @random_proofread.proofread_by.size.should == 2
      @random_proofread.proofread.should be_true
      Changelog.count.should == 0
    end

    it 'updates title, marks not proofread' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: 'Foo Class Name Here'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.name.should == 'Foo Class Name Here'
      @random_instructable.proofread.should_not be_true
      Changelog.count.should == 1
    end

    it 'updates web description' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Description (web)', with: 'Foo Class Description Here'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.description_web.should == 'Foo Class Description Here'
    end

    it 'updates book description' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Description (book)', with: 'Foo Class Description Here'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.description_book.should == 'Foo Class Description Here'
    end

    it 'updates topic and subtopic', js: true do
      @random_instructable.topic.should_not == 'Language'
      @random_instructable.subtopic.should_not == 'Research'
      visit edit_proofreader_instructable_path(@random_instructable)
      select 'Language', from: 'Topic'
      select 'Research', from: 'Subtopic'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.topic.should == 'Language'
      @random_instructable.subtopic.should == 'Research'
    end

    it 'updates culture' do
      @random_instructable.culture.should_not == 'Multiple Cultures'
      visit edit_proofreader_instructable_path(@random_instructable)
      select 'Multiple Cultures', from: 'Culture'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.culture.should == 'Multiple Cultures'
    end

    it 'updates handout_fee' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Handout fee', with: '10'
      fill_in 'Fee itemization', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.handout_fee.should == 10
      @random_instructable.fee_itemization.should == 'This is a test!'
    end

    it 'updates handout_limit' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Handout limit', with: '10'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.handout_limit.should == 10
    end

    it 'updates material_fee' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Material fee', with: '10'
      fill_in 'Fee itemization', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.material_fee.should == 10
      @random_instructable.fee_itemization.should == 'This is a test!'
    end

    it 'updates material_limit' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Material limit', with: '10'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.material_limit.should == 10
    end

    it 'updates fee_itemization' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Fee itemization', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.fee_itemization.should == 'This is a test!'
    end

    it 'updates proofreader_comments' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Comments', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.proofreader_comments.should == 'This is a test!'
    end

    it 'clears proofreader_comments' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Comments', with: ''
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.proofreader_comments.should be_blank
    end

    it 'rejects badness' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: ''
      click_on 'Save and Mark Not Proofread'
      page.should have_content "can't be blank"
      @random_instructable.reload
      @random_instructable.name.should be_present
      @random_instructable.proofread.should_not be_true
    end

    it 'does not create a changelog on badness' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: ''
      click_on 'Save and Mark Not Proofread'
      page.should have_content "can't be blank"
      Changelog.count.should == 0
    end
  end
end
