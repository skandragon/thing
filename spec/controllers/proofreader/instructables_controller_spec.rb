require 'spec_helper'

describe Proofreader::InstructablesController do
  def setup_data
    user = create(:user)
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Music', name: 'MEMusicUnscheduledUnproofed')
    create(:instructable, user_id: user.id, track: 'Middle Eastern',
           topic: 'Dance', name: 'MEDanceUnscheduledProofed',
           proofread: true, is_proofreader: true)
    i = create(:instructable, user_id: user.id, track: 'Middle Eastern',
               topic: 'History', name: 'MEHistoryScheduledProofed',
               proofread: true, is_proofreader: true)
    i.instances.create(start_time: get_date(0), location: 'Foo')
    i = create(:instructable, user_id: user.id, track: 'Performing Arts',
               topic: 'History', name: 'PAHistoryScheduledProofed',
               proofread: true, is_proofreader: true)
    i.instances.create(start_time: get_date(1), location: 'Foo')
    create(:instructable, user_id: user.id, track: 'Archery',
           topic: 'Martial', name: 'ArcheryUnscheduledUnproofed')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Martial', name: 'TracklessArchery')
    create(:instructable, user_id: user.id, track: '',
           topic: 'Music', name: 'TracklessMusic')
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
    end

    it "renders edit form" do
      visit edit_proofreader_instructable_path(@random_instructable)
      find_field('Class title').value.should == @random_instructable.name.to_s
      find_field('Description (book)').value.should == @random_instructable.description_book.to_s
      find_field('Description (web)').value.should == @random_instructable.description_web.to_s
      find_field('Culture').value.should == @random_instructable.culture.to_s
      find_field('Topic').value.should == @random_instructable.topic.to_s
    end

    it "submits, updates, marks proofread" do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: "Foo Class Name Here"
      click_on 'Save and Mark Proofread'
      @random_instructable.reload
      @random_instructable.name.should == "Foo Class Name Here"
      @random_instructable.proofread.should be_true
      Changelog.count.should == 1
    end

    it "submits, updates, marks not proofread" do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: "Foo Class Name Here"
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      @random_instructable.name.should == "Foo Class Name Here"
      @random_instructable.proofread.should_not be_true
      Changelog.count.should == 1
    end

    it "rejects badness" do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: ""
      click_on 'Save and Mark Not Proofread'
      page.should have_content "can't be blank"
      @random_instructable.reload
      @random_instructable.name.should be_present
      @random_instructable.proofread.should_not be_true
    end

    it "does not create a changelog on badness" do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: ""
      click_on 'Save and Mark Not Proofread'
      page.should have_content "can't be blank"
      Changelog.count.should == 0
    end
  end
end
