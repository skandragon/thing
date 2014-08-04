require 'rails_helper'

describe DifferHelper do
  describe '#html_diff' do
    it 'renders for an example diff' do
      html = helper.html_diff('this is a test', 'this is testing')
      html.should == '<span class="differ"><span>this is </span><del>a </del><span>test</span><ins>ing</ins></span>'
    end
  end
end
