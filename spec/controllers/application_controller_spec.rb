require 'rails_helper'

describe ApplicationController, type: :controller do
  it 'formats auth error message' do
    resource = Struct.new('ResourceStruct', :id)
    message = controller.send(:authorization_failure_message, 'FOO', 'BAR', resource.new(12345))
    expect(message).to include('Not authorized.')
    expect(message).to include('FOO')
    expect(message).to include('BAR')
    expect(message).to include('ResourceStruct')
    expect(message).to include('12345')
  end

  describe '#markdown_html' do
    it 'renders markdown' do
      message = controller.send(:markdown_html, 'this is a test')
      expect(message.strip).to eql 'this is a test'
    end

    it 'renders blank string' do
      message = controller.send(:markdown_html, '')
      expect(message.strip).to eql ''
    end

    it 'renders nil as blank string' do
      message = controller.send(:markdown_html, nil)
      expect(message.strip).to eql ''
    end

    it 'renders italic' do
      message = controller.send(:markdown_html, 'this *is* a test')
      expect(message.strip).to eql 'this <em>is</em> a test'
    end

    it 'renders bold' do
      message = controller.send(:markdown_html, 'this **is** a test')
      expect(message.strip).to eql 'this <strong>is</strong> a test'
    end

    it 'renders superscript' do
      message = controller.send(:markdown_html, 'this ^is a test')
      expect(message.strip).to eql 'this <sup>is</sup> a test'
    end

    it 'renders strikethrough' do
      message = controller.send(:markdown_html, 'this ~~is~~ a test')
      expect(message.strip).to eql 'this <del>is</del> a test'
    end

    it 'processes html entities' do
      message = controller.send(:markdown_html, 'this &amp; that&#39;s it')
      expect(message.strip).to eql 'this &amp; that\'s it'
    end

    it 'Skips bold if not in the approved list' do
      message = controller.send(:markdown_html, 'this **is** a test', {
        tags: 'em'
      })
      expect(message.strip).to eql 'this is a test'
    end

    it 'Skips bold if removed from the approved list' do
      message = controller.send(:markdown_html, 'this **is** a test', {
        tags_remove: 'strong'
      })
      expect(message.strip).to eql 'this is a test'
    end

    it 'Allows bold if added to the approved list' do
      message = controller.send(:markdown_html, 'this **is** a test', {
        tags: [],
        tags_add: 'strong'
      })
      expect(message.strip).to eql 'this <strong>is</strong> a test'
    end
  end
end
