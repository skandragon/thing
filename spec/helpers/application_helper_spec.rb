require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#application_name' do
    it 'renders' do
      expect(helper.application_name).to be_present
    end
  end

  describe '#pretty_date_from_now' do
    it 'renders never if date is nil' do
      expect(helper.pretty_date_from_now(nil, 'flarg')).to eql 'flarg'
    end

    it 'adds "ago" on the end if it is in the past' do
      now = Time.now
      Time.should_receive(:now).at_least(:once).and_return(now)
      expect(helper.pretty_date_from_now(now - 10)).to eql 'less than a minute ago'
    end

    it 'prefixes "in" if it is in the future' do
      now = Time.now
      Time.should_receive(:now).at_least(:once).and_return(now)
      expect(helper.pretty_date_from_now(now + 10)).to eql 'in less than a minute'
    end
  end
end
