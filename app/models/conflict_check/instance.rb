class ConflictCheck::Instance
  # If the provided class's start time or end time falls between the
  # current instance's time duration, return an indication.
  def self.time_overlap?(a, b)
    return true if b.start_time.between?(a.start_time, a.end_time - 1)
    return true if b.end_time.between?(a.start_time + 1, a.end_time)
    false
  end
end
