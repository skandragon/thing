require 'rails_helper'

describe LayoutHelper, type: :helper do
  describe '#render_flashes' do
    it 'renders :notice' do
      flash[:notice] = 'FooBarTest'
      helper.render_flashes.should match 'FooBarTest'
      helper.render_flashes.should match 'alert-success'
    end

    it 'renders :error' do
      flash[:error] = 'FooBarTest'
      helper.render_flashes.should match 'FooBarTest'
      helper.render_flashes.should match 'alert-error'
    end

    it 'renders :alert' do
      flash[:alert] = 'FooBarTest'
      helper.render_flashes.should match 'FooBarTest'
      helper.render_flashes.should match 'alert-error'
    end
  end

  describe '#title' do
    it 'sets from a string' do
      helper.should_receive(:application_name).and_return('MyAppName')
      helper.title 'a substring'
      helper.content_for(:window_title).should == 'MyAppName : a substring'
    end

    it 'sets from an array' do
      helper.should_receive(:application_name).and_return('MyAppName')
      helper.title [ 'a substring', 'flarg string' ]
      helper.content_for(:window_title).should == 'MyAppName : a substring : flarg string'
    end
  end

  describe '#title_content' do
    it 'returns just the application title if there is no title content' do
      helper.should_receive(:application_name).and_return('MyAppName')
      helper.title_content.should == 'MyAppName'
    end

    it 'returns the set title' do
      helper.should_receive(:application_name).and_return('MyAppName')
      helper.title 'AlsoInTheTitle'
      helper.title_content.should == 'MyAppName : AlsoInTheTitle'
    end
  end

  describe '#meta' do
    it 'renders a single meta item' do
      helper.meta(flarg: :blatz)
      helper.content_for(:meta_block).should match /flarg/
      helper.content_for(:meta_block).should match /blatz/
    end

    it 'renders two meta items' do
      helper.meta(flarg: :blatz, splat: :flapx)
      helper.content_for(:meta_block).should match /flarg/
      helper.content_for(:meta_block).should match /blatz/
      helper.content_for(:meta_block).should match /splat/
      helper.content_for(:meta_block).should match /flapx/
    end

    it 'works if called more than once' do
      helper.meta(flarg: :blatz)
      helper.meta(splat: :flapx)
      helper.content_for(:meta_block).should match /flarg/
      helper.content_for(:meta_block).should match /blatz/
      helper.content_for(:meta_block).should match /splat/
      helper.content_for(:meta_block).should match /flapx/
    end
  end

  describe '#favicon_links' do
    it 'renders' do
      helper.favicon_links.should be_present
    end
  end

  describe '#back_button' do
    it 'renders without any arguments' do
      helper.back_button.should be_present
    end

    it 'renders a custom label' do
      helper.back_button('XXXBACKXXX').should match /XXXBACKXXX/
    end

    it 'renders a custom target' do
      button = helper.back_button('XXXBACKXXX', 'YYYBACKYYY')
      button.should match /XXXBACKXXX/
      button.should match /YYYBACKYYY/
    end
  end

  describe '#button_link_to' do
    it 'renders the link text' do
      helper.button_link_to('FooBar', 'http://destination').should match '>FooBar</a>'
    end

    it 'renders the link' do
      helper.button_link_to('FooBar', 'http://destination').should match 'href="http://destination"'
    end

    it 'adds btn class' do
      helper.button_link_to('FooBar', 'http://destination').should match 'btn'
    end

    it 'renders the additional classes' do
      link = helper.button_link_to('FooBar', 'http://destination', class: 'splat blatx')
      link.should match 'splat'
      link.should match 'blatx'
    end

    it 'renders the btn class even if passed additional options' do
      helper.button_link_to('FooBar', 'http://destination', class: 'splat').should match 'btn'
    end
  end

  describe '#icon' do
    it 'renders a correct string for bootstrap' do
      helper.icon('flarg').should == '<i class="icon-flarg"></i>'
    end

    it 'renders a correct inverted for bootstrap' do
      helper.icon('flarg', true).should == '<i class="icon-flarg icon-white"></i>'
    end

    it 'renders non-inverse' do
      icon = helper.icon('flarg')
      icon.should match 'icon-flarg'
      icon.should_not match 'icon-white'
    end

    it 'renders inverse normally' do
      icon = helper.icon('flarg', true)
      icon.should match 'icon-flarg'
      icon.should match 'icon-white'
    end
  end

  describe 'revision' do
    it 'returns nil if current_user is nil' do
      helper.should_receive(:current_user).and_return(nil)
      helper.revision.should == nil
    end

    it 'returns nil if current_user is not an admin' do
      current_user = double('object')
      current_user.should_receive(:admin?).and_return(false)
      helper.should_receive(:current_user).at_least(:once).and_return(current_user)
      helper.revision.should == nil
    end

    it 'returns nil if it cannot read the file' do
      current_user = double('object')
      current_user.should_receive(:admin?).and_return(true)
      helper.should_receive(:current_user).at_least(:once).and_return(current_user)
      helper.revision.should == nil
    end

    it 'returns non-nil if it can read the file' do
      current_user = double('object')
      current_user.should_receive(:admin?).and_return(true)
      helper.should_receive(:current_user).at_least(:once).and_return(current_user)
      helper.should_receive(:read_revision).and_return('XXXrevisionXXX')
      helper.revision.should match /XXXrevisionXXX/
    end
  end
end
