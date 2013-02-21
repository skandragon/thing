require 'spec_helper'

describe GoogleHelper do
  describe '#google_analytics' do
    it 'does not render analytics code if not production' do
      Rails.should_receive(:env).and_return('not production')
      helper.google_analytics.should_not match /google-analytics/
    end

    it 'does not render analytics code if production but key is not set' do
      Rails.should_receive(:env).at_least(:once).and_return('production')
      APP_CONFIG[:google_analytics_id] = 'XXXKEYXXX'
      helper.google_analytics.should match /google-analytics/
      helper.google_analytics.should match /XXXKEYXXX/
    end

    it 'renders window.trackEvent if not production' do
      Rails.should_receive(:env).and_return('not production')
      helper.google_analytics.should match /window\.trackEvent/
    end
  end
end
