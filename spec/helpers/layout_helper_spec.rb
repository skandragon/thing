require 'rails_helper'

describe LayoutHelper, type: :helper do
  describe '#render_flashes' do
    it 'renders :notice' do
      flash[:notice] = 'FooBarTestNotice'
      expect(helper.render_flashes).to match 'FooBarTestNotice'
      expect(helper.render_flashes).to match 'alert-success'
    end

    it 'renders :error' do
      flash[:error] = 'FooBarTestError'
      expect(helper.render_flashes).to match 'FooBarTestError'
      expect(helper.render_flashes).to match 'alert-error'
    end

    it 'renders :alert' do
      flash[:alert] = 'FooBarTestAlert'
      expect(helper.render_flashes).to match 'FooBarTestAlert'
      expect(helper.render_flashes).to match 'alert-error'
    end
  end

  describe '#title' do
    it 'sets from a string' do
      helper.should_receive(:application_name).and_return('MyAppName')
      helper.title 'a substring'
      expect(helper.content_for(:window_title)).to eql 'MyAppName : a substring'
    end

    it 'sets from an array' do
      helper.should_receive(:application_name).and_return('MyAppName')
      helper.title [ 'a substring', 'flarg string' ]
      expect(helper.content_for(:window_title)).to eql 'MyAppName : a substring : flarg string'
    end
  end

  describe '#title_content' do
    it 'returns just the application title if there is no title content' do
      helper.should_receive(:application_name).and_return('MyAppName')
      expect(helper.title_content).to eql 'MyAppName'
    end

    it 'returns the set title' do
      helper.should_receive(:application_name).and_return('MyAppName')
      helper.title 'AlsoInTheTitle'
      expect(helper.title_content).to eql 'MyAppName : AlsoInTheTitle'
    end
  end

  describe '#meta' do
    it 'renders a single meta item' do
      helper.meta(flarg: :blatz)
      expect(helper.content_for(:meta_block)).to match /flarg/
      expect(helper.content_for(:meta_block)).to match /blatz/
    end

    it 'renders two meta items' do
      helper.meta(flarg: :blatz, splat: :flapx)
      expect(helper.content_for(:meta_block)).to match /flarg/
      expect(helper.content_for(:meta_block)).to match /blatz/
      expect(helper.content_for(:meta_block)).to match /splat/
      expect(helper.content_for(:meta_block)).to match /flapx/
    end

    it 'works if called more than once' do
      helper.meta(flarg: :blatz)
      helper.meta(splat: :flapx)
      expect(helper.content_for(:meta_block)).to match /flarg/
      expect(helper.content_for(:meta_block)).to match /blatz/
      expect(helper.content_for(:meta_block)).to match /splat/
      expect(helper.content_for(:meta_block)).to match /flapx/
    end
  end

  describe '#favicon_links' do
    it 'renders' do
      expect(helper.favicon_links).to be_present
    end
  end

  describe '#back_button' do
    it 'renders without any arguments' do
      expect(helper.back_button).to be_present
    end

    it 'renders a custom label' do
      expect(helper.back_button('XXXBACKXXX')).to match /XXXBACKXXX/
    end

    it 'renders a custom target' do
      button = helper.back_button('XXXBACKXXX', 'YYYBACKYYY')
      expect(button).to match /XXXBACKXXX/
      expect(button).to match /YYYBACKYYY/
    end
  end

  describe '#button_link_to' do
    it 'renders the link text' do
      expect(helper.button_link_to('FooBar', 'http://destination')).to match '>FooBar</a>'
    end

    it 'renders the link' do
      expect(helper.button_link_to('FooBar', 'http://destination')).to match 'href="http://destination"'
    end

    it 'adds btn class' do
      expect(helper.button_link_to('FooBar', 'http://destination')).to match 'btn'
    end

    it 'renders the additional classes' do
      link = helper.button_link_to('FooBar', 'http://destination', class: 'splat blatx')
      expect(link).to match 'splat'
      expect(link).to match 'blatx'
    end

    it 'renders the btn class even if passed additional options' do
      expect(helper.button_link_to('FooBar', 'http://destination', class: 'splat')).to match 'btn'
    end
  end

  describe '#icon' do
    it 'renders a correct string for bootstrap' do
      expect(helper.icon('flarg')).to eql '<i class="icon-flarg"></i>'
    end

    it 'renders a correct inverted for bootstrap' do
      expect(helper.icon('flarg', true)).to eql '<i class="icon-flarg icon-white"></i>'
    end

    it 'renders non-inverse' do
      icon = helper.icon('flarg')
      expect(icon).to match 'icon-flarg'
      expect(icon).to_not match 'icon-white'
    end

    it 'renders inverse normally' do
      icon = helper.icon('flarg', true)
      expect(icon).to match 'icon-flarg'
      expect(icon).to match 'icon-white'
    end
  end

  describe 'revision' do
    it 'returns nil if current_user is nil' do
      helper.should_receive(:current_user).and_return(nil)
      expect(helper.revision).to be_nil
    end

    it 'returns nil if current_user is not an admin' do
      current_user = double('object')
      current_user.should_receive(:admin?).and_return(false)
      helper.should_receive(:current_user).at_least(:once).and_return(current_user)
      expect(helper.revision).to be_nil
    end

    it 'returns nil if it cannot read the file' do
      current_user = double('object')
      current_user.should_receive(:admin?).and_return(true)
      helper.should_receive(:current_user).at_least(:once).and_return(current_user)
      expect(helper.revision).to be_nil
    end

    it 'returns non-nil if it can read the file' do
      current_user = double('object')
      current_user.should_receive(:admin?).and_return(true)
      helper.should_receive(:current_user).at_least(:once).and_return(current_user)
      helper.should_receive(:read_revision).and_return('XXXrevisionXXX')
      expect(helper.revision).to match /XXXrevisionXXX/
    end
  end
end
