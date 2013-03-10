class ConflictCheck::Instance
  # If the provided class's start time or end time falls between the
  # current instance's time duration, return an indication.
  def self.time_overlap?(a, b)
    return false if a.start_time.blank? or b.start_time.blank?
    return true if b.start_time.between?(a.start_time, a.end_time - 1)
    return true if b.end_time.between?(a.start_time + 1, a.end_time)
    false
  end

  # return true if the class location is identical
  def self.location_overlap?(a, b)
    if a.instructable.location_nontrack? and b.instructable.location_nontrack?
      return a.instructable.camp_name == b.instructable.camp_name
    elsif !a.instructable.location_nontrack? and !b.instructable.location_nontrack?
      return false if a.location.blank? or b.location.blank?
      return a.location == b.location
    end
    false
  end

  # return true only if user_id fields are equal
  def self.instructor_overlap?(a, b)
    a.instructable.user_id == b.instructable.user_id
  end

  #
  # Put all of the sub-overlap checks together.
  #
  def self.overlap?(a, b)
    return [] unless time_overlap?(a, b)
    ret = []
    ret << :location if location_overlap?(a, b)
    ret << :instructor if instructor_overlap?(a, b)
    ret
  end
end
