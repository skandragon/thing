require 'spec_helper'

describe CalendarsController do
  def create_instructables
    @user1 = create(:instructor)
    @user2 = create(:instructor)
    @instructable1 = create(:scheduled_instructable, user_id: @user1.id)
    @instructable2 = create(:scheduled_instructable, user_id: @user2.id)
  end

  describe 'HTML' do
      describe 'without classes' do
        it 'renders full' do
          visit calendars_path
        end
      end

      describe 'with classes' do
        before :each do
          create_instructables
        end

        it 'renders full' do
          visit calendars_path
          page.should have_content @instructable1.name
          page.should have_content @instructable2.name
        end
      end
    end


  describe 'XSLS' do
    describe 'without classes' do
      it 'renders full' do
        visit calendars_path(format: :xlsx)
        page.response_headers['Content-Type'].should == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end
    end

    describe 'with classes' do
      before :each do
        create_instructables
      end

      it 'renders full' do
        visit calendars_path(format: :xlsx)
        page.response_headers['Content-Type'].should == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end
    end
  end

  describe 'CSV' do
    describe 'without classes' do
      it 'renders full' do
        visit calendars_path(format: :csv)
        page.response_headers['Content-Type'].should == 'text/csv'
        page.body.should_not be_blank
      end
    end

    describe 'with classes' do
      before :each do
        create_instructables
      end

      it 'renders full' do
        visit calendars_path(format: :csv)
        page.response_headers['Content-Type'].should == 'text/csv'
        page.body.should_not be_blank
        page.body.should match @instructable1.name
        page.body.should match @instructable2.name
      end
    end
  end

  describe 'ICS' do
    describe 'without classes' do
      it 'renders full' do
        visit calendars_path(format: :ics)
        page.response_headers['Content-Type'].should == 'text/calendar'
        page.body.should_not be_blank
        page.body[0..14].should == 'BEGIN:VCALENDAR'
      end
    end

    describe 'with classes' do
      before :each do
        create_instructables
      end

      it 'renders full' do
        visit calendars_path(format: :ics)
        page.response_headers['Content-Type'].should == 'text/calendar'
        page.body.should_not be_blank
        page.body[0..14].should == 'BEGIN:VCALENDAR'
        page.body.should match @instructable1.name
        page.body.should match @instructable2.name
      end
    end
  end

  describe 'PDF' do
    describe 'without classes' do
      it 'renders full' do
        visit calendars_path(format: :pdf)
        page.response_headers['Content-Type'].should == 'application/pdf'
        page.body.should_not be_blank
        page.body[0..3].should == '%PDF'
      end

      it 'renders brief' do
        visit calendars_path(format: :pdf, brief: true)
        page.response_headers['Content-Type'].should == 'application/pdf'
        page.body.should_not be_blank
        page.body[0..3].should == '%PDF'
      end
    end

    describe 'with classes' do
      before :each do
        create_instructables
      end

      it 'renders full' do
        visit calendars_path(format: :pdf)
        page.response_headers['Content-Type'].should == 'application/pdf'
        page.body.should_not be_blank
        page.body[0..3].should == '%PDF'
      end

      it 'renders brief' do
        visit calendars_path(format: :pdf, brief: true)
        page.response_headers['Content-Type'].should == 'application/pdf'
        page.body.should_not be_blank
        page.body[0..3].should == '%PDF'
      end
    end
  end
end
