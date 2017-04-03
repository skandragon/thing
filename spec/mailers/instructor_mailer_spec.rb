require 'rails_helper'

describe InstructorMailer do
  before :each do
    ActionMailer::Base.deliveries.clear
    @user = create(:instructor)
  end

  it 'renders if there are no track classes' do
    InstructorMailer.send_message(@user, 'Subject Goes Here').deliver
    expect(ActionMailer::Base.deliveries.size).to eql 1
    body = ActionMailer::Base.deliveries.first.body.raw_source
    expect(body).to include "Dear #{@user.titled_sca_name}"
  end
end
