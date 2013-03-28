require 'spec_helper'

describe ApplicationHelper do
  describe '#application_name' do
    it 'renders' do
      helper.application_name.should be_present
    end
  end

  describe '#pretty_date_from_now' do
    it 'renders never if date is nil' do
      helper.pretty_date_from_now(nil, 'flarg').should == 'flarg'
    end

    it 'adds "ago" on the end if it is in the past' do
      now = Time.now
      Time.should_receive(:now).at_least(:once).and_return(now)
      helper.pretty_date_from_now(now - 10).should == 'less than a minute ago'
    end

    it 'prefixes "in" if it is in the future' do
      now = Time.now
      Time.should_receive(:now).at_least(:once).and_return(now)
      helper.pretty_date_from_now(now + 10).should == 'in less than a minute'
    end
  end

  describe '#markdown_html' do
    it "renders markdown" do
      message = helper.markdown_html("this is a test")
      message.strip.should == '<p>this is a test</p>'
    end

    it "renders blank string" do
      message = helper.markdown_html("")
      message.strip.should == ''
    end

    it "renders nil as blank string" do
      message = helper.markdown_html(nil)
      message.strip.should == ''
    end

    it "renders italic" do
      message = helper.markdown_html("this *is* a test")
      message.strip.should == '<p>this <em>is</em> a test</p>'
    end

    it "renders bold" do
      message = helper.markdown_html("this **is** a test")
      message.strip.should == '<p>this <strong>is</strong> a test</p>'
    end
  end
end
