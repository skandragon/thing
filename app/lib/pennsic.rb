class Pennsic
  def self.year
    Time.now.year - 1972 + 1
  end

  def self.as
    'LII'
  end

  def self.calendar_year
    Time.now.year
  end

  def self.dates
    (Date.parse('2017-07-28')..Date.parse('2017-08-13')).to_a
  end

  def self.dates_formatted
    dates.map(&:to_s)
  end

  def self.class_dates_raw
    (Date.parse('2017-08-01')..Date.parse('2017-08-11')).to_a
  end

  def self.class_dates
    class_dates_raw.map(&:to_s)
  end

  def self.class_times
    [ '9am to Noon', 'Noon to 3pm', '3pm to 6pm', 'After 6pm' ]
  end
end
