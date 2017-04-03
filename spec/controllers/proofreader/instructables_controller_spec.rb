require 'rails_helper'

describe Proofreader::InstructablesController, type: :controller do
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
    expect(page).to have_content 'Not authorized.'
  end

  describe 'index' do
    before :each do
      setup_data
      log_in proofreader: true
      visit proofreader_instructables_path
    end

    it 'renders as proofreader' do
      expect(page).to have_button 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnproofed'
      expect(page).to have_content 'MEDanceUnscheduledProofed'
      expect(page).to have_content 'MEHistoryScheduledProofed'
      expect(page).to have_content 'PAHistoryScheduledProofed'
    end

    it 'allows selection of track' do
      expect(page).to have_select('track')
    end

    it 'filters based on track' do
      select 'Middle Eastern', from: 'track'
      click_on 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnproofed'
      expect(page).to have_content 'MEDanceUnscheduledProofed'
      expect(page).to have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on track of No Track' do
      select 'No Track', from: 'track'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnscheduledUnproofed'
      expect(page).to_not have_content 'MEDanceUnscheduledProofed'
      expect(page).to_not have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on proofread = 1' do
      select 'Proofread', from: 'proofread'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnproofed'
      expect(page).to have_content 'MEDanceUnscheduledProofed'
      expect(page).to have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on proofread = 0' do
      select 'Not Proofread', from: 'proofread'
      click_on 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnproofed'
      expect(page).to_not have_content 'MEDanceUnscheduledProofed'
      expect(page).to_not have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on topic' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      expect(page).to_not have_content 'MEMusicUnscheduledUnproofed'
      expect(page).to have_content 'MEDanceUnscheduledProofed'
      expect(page).to_not have_content 'MEHistoryScheduledProofed'
    end

    it 'filters based on partial class name' do
      fill_in 'search', with: 'Unscheduled'
      click_on 'Filter'
      expect(page).to have_content 'MEMusicUnscheduledUnproofed'
      expect(page).to have_content 'MEDanceUnscheduledProofed'
      expect(page).to_not have_content 'MEHistoryScheduledProofed'
    end

    it 'clears the form' do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      click_on 'Clear'
      expect(page).to have_content 'MEMusicUnscheduledUnproofed'
      expect(page).to have_content 'MEDanceUnscheduledProofed'
      expect(page).to have_content 'MEHistoryScheduledProofed'
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
      expect(find_field('Class title').value).to eql @random_instructable.name.to_s
      expect(find_field('Description (book)').value).to eql @random_instructable.description_book.to_s
      expect(find_field('Description (web)').value).to eql @random_instructable.description_web.to_s
      expect(find_field('Culture').value).to eql @random_instructable.culture.to_s
      expect(find_field('Topic').value).to eql @random_instructable.topic.to_s
    end

    it 'submits, updates, marks proofread' do
      visit edit_proofreader_instructable_path(@random_proofread)
      fill_in 'Class title', with: 'Foo Class Name Here'
      click_on 'Save and Mark Proofread'
      @random_proofread.reload
      expect(@random_proofread.name).to eql 'Foo Class Name Here'
      expect(@random_proofread.proofread).to_not be_truthy
      expect(@random_proofread.proofread_by).to eql [current_user.id]
      expect(Changelog.count).to eql 1
      cl = Changelog.first
      expect(cl.changelog).to_not eql({})
      expect(cl.changelog).to have_key('name')
    end

    it 'marks proofread when really proofread' do
      expect(@random_proofread.proofread_by).to_not include(current_user.id)
      visit edit_proofreader_instructable_path(@random_proofread)
      click_on 'Save and Mark Proofread'
      @random_proofread.reload
      expect(@random_proofread.proofread_by).to include(current_user.id)
      expect(@random_proofread.proofread_by.size).to eql 2
      expect(@random_proofread.proofread).to be_truthy
      expect(Changelog.count).to eql 0
    end

    it 'updates title, marks not proofread' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: 'Foo Class Name Here'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.name).to eql 'Foo Class Name Here'
      expect(@random_instructable.proofread).to_not be_truthy
      expect(Changelog.count).to eql 1
    end

    it 'updates web description' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Description (web)', with: 'Foo Class Description Here'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.description_web).to eql 'Foo Class Description Here'
    end

    it 'updates book description' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Description (book)', with: 'Foo Class Description Here'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.description_book).to eql 'Foo Class Description Here'
    end

    it 'updates topic and subtopic', js: true do
      expect(@random_instructable.topic).to_not eql 'Language'
      expect(@random_instructable.subtopic).to_not eql 'Research'
      visit edit_proofreader_instructable_path(@random_instructable)
      select 'Language', from: 'Topic'
      select 'Research', from: 'Subtopic'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.topic).to eql 'Language'
      expect(@random_instructable.subtopic).to eql 'Research'
    end

    it 'updates culture' do
      expect(@random_instructable.culture).to_not eql 'Multiple Cultures'
      visit edit_proofreader_instructable_path(@random_instructable)
      select 'Multiple Cultures', from: 'Culture'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.culture).to eql 'Multiple Cultures'
    end

    it 'updates handout_fee' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Handout fee', with: '10'
      fill_in 'Fee itemization', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.handout_fee).to eql 10.0
      expect(@random_instructable.fee_itemization).to eql 'This is a test!'
    end

    it 'updates handout_limit' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Handout limit', with: '10'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.handout_limit).to eql 10
    end

    it 'updates material_fee' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Material fee', with: '10'
      fill_in 'Fee itemization', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.material_fee).to eql 10.0
      expect(@random_instructable.fee_itemization).to eql 'This is a test!'
    end

    it 'updates material_limit' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Material limit', with: '10'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.material_limit).to eql 10
    end

    it 'updates fee_itemization' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Fee itemization', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.fee_itemization).to eql 'This is a test!'
    end

    it 'updates proofreader_comments' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Comments', with: 'This is a test!'
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.proofreader_comments).to eql 'This is a test!'
    end

    it 'clears proofreader_comments' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Comments', with: ''
      click_on 'Save and Mark Not Proofread'
      @random_instructable.reload
      expect(@random_instructable.proofreader_comments).to be_blank
    end

    it 'rejects badness' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: ''
      click_on 'Save and Mark Not Proofread'
      expect(page).to have_content "can't be blank"
      @random_instructable.reload
      expect(@random_instructable.name).to be_present
      expect(@random_instructable.proofread).to_not be_truthy
    end

    it 'does not create a changelog on badness' do
      visit edit_proofreader_instructable_path(@random_instructable)
      fill_in 'Class title', with: ''
      click_on 'Save and Mark Not Proofread'
      expect(page).to have_content "can't be blank"
      expect(Changelog.count).to eql 0
    end
  end
end
