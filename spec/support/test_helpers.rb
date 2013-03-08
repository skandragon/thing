def get_date(index, offset = 0)
  date = Instructable::CLASS_DATES[0]
  Time.zone.parse(date.to_s) + offset
end
