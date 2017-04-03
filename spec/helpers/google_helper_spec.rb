require 'rails_helper'

describe GoogleHelper, type: :helper do
  describe '#google_analytics' do
    it 'does not render analytics code if not production' do
      Rails.should_receive(:env).and_return('not production')
      expect(helper.google_analytics).to_not match /google-analytics/
    end

    it 'does not render analytics code if production but key is not set' do
      Rails.should_receive(:env).at_least(:once).and_return('production')
      APP_CONFIG[:google_analytics_id] = 'XXXKEYXXX'
      expect(helper.google_analytics).to match /google-analytics/
      expect(helper.google_analytics).to match /XXXKEYXXX/
    end

    it 'renders window.trackEvent if not production' do
      Rails.should_receive(:env).and_return('not production')
      expect(helper.google_analytics).to match /window\.trackEvent/
    end
  end
end
