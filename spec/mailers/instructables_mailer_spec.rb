require 'rails_helper'

describe InstructablesMailer do
  before :each do
    ActionMailer::Base.deliveries.clear
    @user = create(:instructor)
  end

  it 'renders if there are no track classes' do
    InstructablesMailer.track_status('example@example.com', 'Middle Eastern', []).deliver
    expect(ActionMailer::Base.deliveries.size).to eql 1
    body = ActionMailer::Base.deliveries.first.body
    expect(body).to match 'Track summary for Middle Eastern'
    expect(body).to match /0 total classes/
    expect(body).to match /0 classes need to be scheduled/
    expect(body).to match /Good job!  There are no classes which need to be scheduled./
    expect(body).to match /No conflicts found./
  end

  it 'renders list if one class is unscheduled' do
    create(:instructable, user_id: @user.id, name: 'Unscheduled Class One', track: 'Middle Eastern')
    create(:instructable, user_id: @user.id, name: 'Unscheduled Class Two', track: 'Middle Eastern')
    i = create(:instructable, user_id: @user.id, name: 'Fully Scheduled Class One', track: 'Middle Eastern')
    i.instances.create(start_time: get_date(1), location: 'Touch the Earth')
    instructables = Instructable.where(track: 'Middle Eastern')
    InstructablesMailer.track_status('example@example.com', 'Middle Eastern', instructables).deliver
    expect(ActionMailer::Base.deliveries.size).to eql 1
    body = ActionMailer::Base.deliveries.first.body
    expect(body).to match /3 total classes/
    expect(body).to match /2 classes need to be scheduled/
    expect(body).to match /Unscheduled Class One/
    expect(body).to match /Unscheduled Class Two/
    expect(body).to_not match /Fully Scheduled Class One/
  end

  it 'renders conflicts' do
    i = create(:instructable, user_id: @user.id, name: 'Conflicted Class One', track: 'Middle Eastern')
    i.instances.create(start_time: get_date(1), location: 'Touch the Earth')
    i = create(:instructable, user_id: @user.id, name: 'Conflicted Class Two', track: 'Middle Eastern')
    i.instances.create(start_time: get_date(1), location: 'Touch the Earth')
    instructables = Instructable.where(track: 'Middle Eastern')
    InstructablesMailer.track_status('example@example.com', 'Middle Eastern', instructables).deliver
    expect(ActionMailer::Base.deliveries.size).to eql 1
    body = ActionMailer::Base.deliveries.first.body
    expect(body).to match /2 total classes/
    expect(body).to match /0 classes need to be scheduled/
    expect(body).to match /1 conflict\./
    expect(body).to match /Conflicted Class One/
    expect(body).to match /Conflicted Class Two/
    expect(body).to match /Touch the Earth/
    expect(body).to match @user.titled_sca_name
    expect(body).to match /Conflict Type: location, instructor/
  end
end
