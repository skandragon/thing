require 'spec_helper'

def setup_data
  user = create(:user)
  create(:instructable, user_id: user.id, tract: "Middle Eastern",
         topic: "Music", name: "MEMusicUnscheduledUnapproved")
  create(:instructable, user_id: user.id, tract: "Middle Eastern",
         topic: "Dance", name: "MEDanceUnscheduledApproved",
          approved: true)
  create(:instructable, user_id: user.id, tract: "Middle Eastern",
         topic: "History", name: "MEHistoryScheduledApproved",
         approved: true, start_time: "10:00:00")
  create(:instructable, user_id: user.id, tract: "Performing Arts",
        topic: "History", name: "PEHistoryScheduledApproved",
        approved: true, start_time: "10:00:00")
end

describe Coordinator::InstructablesController do
  describe "search (admin)" do
    before :each do
      setup_data
      log_in coordinator_tract: "Middle Eastern", admin: true
      visit coordinator_instructables_path
    end

    it "renders as admin" do
      select '', from: 'tract'
      click_on "Filter"
      page.should have_content "MEMusicUnscheduledUnapproved"
      page.should have_content "MEDanceUnscheduledApproved"
      page.should have_content "MEHistoryScheduledApproved"
      page.should have_content 'PEHistoryScheduledApproved'
    end

    it "renders as admin for other tracts" do
      select 'Performing Arts', from: 'tract'
      click_on "Filter"
      page.should_not have_content "MEMusicUnscheduledUnapproved"
      page.should_not have_content "MEDanceUnscheduledApproved"
      page.should_not have_content "MEHistoryScheduledApproved"
      page.should have_content 'PEHistoryScheduledApproved'
    end
  end

  describe "search (non-admin)" do
    before :each do
      setup_data
      log_in coordinator_tract: "Middle Eastern"
      visit coordinator_instructables_path
    end

    it "renders as coordinator" do
      page.should have_button "Filter"
      page.should have_content "MEMusicUnscheduledUnapproved"
      page.should have_content "MEDanceUnscheduledApproved"
      page.should have_content "MEHistoryScheduledApproved"
      page.should_not have_content 'PEHistoryScheduledApproved'
    end

    it "filters based on approved = 1" do
      select 'Approved', from: 'approved'
      click_on "Filter"
      page.should_not have_content "MEMusicUnscheduledUnapproved"
      page.should have_content "MEDanceUnscheduledApproved"
      page.should have_content "MEHistoryScheduledApproved"
    end

    it "filters based on approved = 0" do
      select 'Not Approved', from: 'approved'
      click_on "Filter"
      page.should have_content "MEMusicUnscheduledUnapproved"
      page.should_not have_content "MEDanceUnscheduledApproved"
      page.should_not have_content "MEHistoryScheduledApproved"
    end

    it "filters based on scheduled = 1" do
      select 'Scheduled', from: 'scheduled'
      click_on "Filter"
      page.should_not have_content "MEMusicUnscheduledUnapproved"
      page.should_not have_content "MEDanceUnscheduledApproved"
      page.should have_content "MEHistoryScheduledApproved"
    end

    it "filters based on scheduled = 0" do
      select 'Not Scheduled', from: 'scheduled'
      click_on "Filter"
      page.should have_content "MEMusicUnscheduledUnapproved"
      page.should have_content "MEDanceUnscheduledApproved"
      page.should_not have_content "MEHistoryScheduledApproved"
    end

    it "filters based on topic" do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      page.should_not have_content "MEMusicUnscheduledUnapproved"
      page.should have_content "MEDanceUnscheduledApproved"
      page.should_not have_content "MEHistoryScheduledApproved"
    end

    it "filters based on partial class name" do
      fill_in 'search', with: 'Unscheduled'
      click_on 'Filter'
      page.should have_content "MEMusicUnscheduledUnapproved"
      page.should have_content "MEDanceUnscheduledApproved"
      page.should_not have_content "MEHistoryScheduledApproved"
    end

    it "clears the form" do
      select 'Dance', from: 'topic'
      click_on 'Filter'
      click_on 'Clear'
      page.should have_content "MEMusicUnscheduledUnapproved"
      page.should have_content "MEDanceUnscheduledApproved"
      page.should have_content "MEHistoryScheduledApproved"
    end
  end
end
