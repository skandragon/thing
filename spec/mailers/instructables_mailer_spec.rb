require 'spec_helper'

describe InstructablesMailer do
  before :each do
    ActionMailer::Base.deliveries.clear
    @user = create(:instructor)
  end

  it "renders if there are no track classes" do
    mailer = InstructablesMailer.track_status('example@example.com', 'Middle Eastern', []).deliver
    ActionMailer::Base.deliveries.size.should == 1
    body = ActionMailer::Base.deliveries.first.body
    body.should match "Track summary for Middle Eastern"
    body.should =~ /0 total classes/
    body.should =~ /0 classes need to be scheduled/
    body.should =~ /Good job!  There are no classes which need to be scheduled./
    body.should =~ /No conflicts found./
  end

  it "renders list if one class is unscheduled" do
    create(:instructable, user_id: @user.id, name: "Unscheduled Class One", track: "Middle Eastern")
    create(:instructable, user_id: @user.id, name: "Unscheduled Class Two", track: "Middle Eastern")
    i = create(:instructable, user_id: @user.id, name: "Fully Scheduled Class One", track: "Middle Eastern")
    i.instances.create(start_time: get_date(1), location: 'Touch the Earth')
    instructables = Instructable.where(track: "Middle Eastern")
    mailer = InstructablesMailer.track_status('example@example.com', 'Middle Eastern', instructables).deliver
    ActionMailer::Base.deliveries.size.should == 1
    body = ActionMailer::Base.deliveries.first.body
    body.should =~ /3 total classes/
    body.should =~ /2 classes need to be scheduled/
    body.should =~ /Unscheduled Class One/
    body.should =~ /Unscheduled Class Two/
    body.should_not =~ /Fully Scheduled Class One/
  end

  it "renders conflicts" do
    i = create(:instructable, user_id: @user.id, name: "Conflicted Class One", track: "Middle Eastern")
    i.instances.create(start_time: get_date(1), location: "Touch the Earth")
    i = create(:instructable, user_id: @user.id, name: "Conflicted Class Two", track: "Middle Eastern")
    i.instances.create(start_time: get_date(1), location: "Touch the Earth")
    instructables = Instructable.where(track: "Middle Eastern")
    mailer = InstructablesMailer.track_status('example@example.com', 'Middle Eastern', instructables).deliver
    ActionMailer::Base.deliveries.size.should == 1
    body = ActionMailer::Base.deliveries.first.body
    body.should =~ /2 total classes/
    body.should =~ /0 classes need to be scheduled/
    body.should =~ /1 conflict\./
    body.should =~ /Conflicted Class One/
    body.should =~ /Conflicted Class Two/
    body.should =~ /Touch the Earth/
    body.should match @user.titled_sca_name
    body.should =~ /Conflict Type: location, instructor/
  end
end
