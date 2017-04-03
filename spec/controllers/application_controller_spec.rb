require 'rails_helper'

describe ApplicationController, type: :controller do
  it 'formats auth error message' do
    resource = Struct.new('ResourceStruct', :id)
    message = controller.send(:authorization_failure_message, 'FOO', 'BAR', resource.new(12345))
    message.should include('Not authorized.')
    message.should include('FOO')
    message.should include('BAR')
    message.should include('ResourceStruct')
    message.should include('12345')
  end

  describe '#markdown_html' do
    it 'renders markdown' do
      message = controller.send(:markdown_html, 'this is a test')
      message.strip.should == 'this is a test'
    end

    it 'renders blank string' do
      message = controller.send(:markdown_html, '')
      message.strip.should == ''
    end

    it 'renders nil as blank string' do
      message = controller.send(:markdown_html, nil)
      message.strip.should == ''
    end

    it 'renders italic' do
      message = controller.send(:markdown_html, 'this *is* a test')
      message.strip.should == 'this <em>is</em> a test'
    end

    it 'renders bold' do
      message = controller.send(:markdown_html, 'this **is** a test')
      message.strip.should == 'this <strong>is</strong> a test'
    end

    it 'renders superscript' do
      message = controller.send(:markdown_html, 'this ^is a test')
      message.strip.should == 'this <sup>is</sup> a test'
    end

    it 'renders strikethrough' do
      message = controller.send(:markdown_html, 'this ~~is~~ a test')
      message.strip.should == 'this <del>is</del> a test'
    end

    it 'processes html entities' do
      message = controller.send(:markdown_html, 'this &amp; that&#39;s it')
      message.strip.should == 'this &amp; that\'s it'
    end

    it 'Skips bold if not in the approved list' do
      message = controller.send(:markdown_html, 'this **is** a test', {
        tags: 'em'
      })
      message.strip.should == 'this is a test'
    end

    it 'Skips bold if removed from the approved list' do
      message = controller.send(:markdown_html, 'this **is** a test', {
        tags_remove: 'strong'
      })
      message.strip.should == 'this is a test'
    end

    it 'Allows bold if added to the approved list' do
      message = controller.send(:markdown_html, 'this **is** a test', {
        tags: [],
        tags_add: 'strong'
      })
      message.strip.should == 'this <strong>is</strong> a test'
    end
  end
end
