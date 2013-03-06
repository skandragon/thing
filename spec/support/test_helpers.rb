def get_date(index, offset = 0)
  date = Instructable::CLASS_DATES[0]
  Time.parse("#{date.to_s}").in_time_zone + offset
end
