require 'spec_helper'

describe Pennsic do
  it 'returns the current year' do
    Pennsic.year.should >= 43
  end

  it 'returns the current calendar_year' do
    Pennsic.calendar_year.should == Time.now.year
  end
end
