require 'rails_helper'

describe Pennsic do
  it 'returns the current year' do
    expect(Pennsic.year >= 43).to be_truthy
  end

  it 'returns the current calendar_year' do
    expect(Pennsic.calendar_year).to eql Time.now.year
  end
end
