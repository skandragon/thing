class Pennsic
  def self.year
    44
  end

  def self.calendar_year
    Time.now.year
  end
  
  def self.dates
    (Date.parse('2015-07-24')..Date.parse('2015-08-09')).to_a
  end
  
  def self.dates_formatted
    dates.map(&:to_s)
  end
  
  def self.class_dates
    (Date.parse('2015-07-27')..Date.parse('2015-08-07')).to_a.map(&:to_s)
  end
  
  def self.class_times
    [ '9am to Noon', 'Noon to 3pm', '3pm to 6pm', 'After 6pm' ]
  end
end
