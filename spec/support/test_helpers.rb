def get_date(index, offset = 0)
  date = Instructable::CLASS_DATES[index]
  Time.zone.parse(date.to_s) + offset
end
