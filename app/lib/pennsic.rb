class Pennsic
  def self.year
    Time.now.year - 1972 + 1
  end

  def self.as
    'LI'
  end

  def self.calendar_year
    Time.now.year
  end

  def self.dates
    (Date.parse('2016-07-29')..Date.parse('2016-08-14')).to_a
  end

  def self.dates_formatted
    dates.map(&:to_s)
  end

  def self.class_dates
    (Date.parse('2016-08-01')..Date.parse('2016-08-12')).to_a.map(&:to_s)
  end

  def self.class_times
    [ '9am to Noon', 'Noon to 3pm', '3pm to 6pm', 'After 6pm' ]
  end
end
