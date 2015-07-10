require 'rails_helper'

describe Admin::ReportsController, type: :controller do
  def create_instructables(count, *args)
    count.times do
      instructable = create(:scheduled_instructable, *args)
      instructable.reload
      @instructables << instructable
    end
  end

  before :each do
    log_in admin: true

    @user = create(:instructor)
    @instructables = []
    create_instructables(10, track: 'Middle Eastern', user_id: @user.id)
  end

  it 'shows a flash message for html' do
    visit instructor_signin_admin_reports_path
    page.should have_content 'Only PDF format for instructor sign-in is supported.'
  end

  it 'renders pdf' do
    visit instructor_signin_admin_reports_path(format: :pdf)
    page.response_headers['Content-Type'].should == 'application/pdf'
    page.body.should_not be_blank
    page.body[0..3].should == '%PDF'
  end
end
