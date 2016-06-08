class ConflictCheck
  IGNORED_INSTRUCTORS = [
    'Pennsic Performing Arts',
    'Artisans Row',
    'Artimisia Lacebrayder',
  ]

  def self.conflicts(options = {})
    #
    # If options[:track] then limit returned conflicts to instances
    # that involve that track in some way.  Unfortunately, we still need
    # to retrieve all the instances which have a start_time set, because
    # we may have a track class conflict with a non-track class.
    #
    track_filter = options[:track]

    instances = Instance.where('start_time IS NOT NULL').order(:start_time).includes(:instructable => [ :user ])
    return [] if instances.size < 2

    ret = []

    while instances.size > 0
      instance = instances.pop
      next if instances.size == 0
      instances.each do |other|
        next unless track_filter.blank? or [instance.instructable.track, other.instructable.track].include?(track_filter)
        conflicts = instance_overlap?(instance, other)
        if conflicts.size > 0
          ret << [conflicts, [instance, other]]
        end
      end
    end

    ret
  end

  # If the provided class's start time or end time falls between the
  # current instance's time duration, return an indication.
  def self.instance_time_overlap?(a, b)
    return false if a.start_time.blank? or b.start_time.blank?
    return true if b.start_time.between?(a.start_time, a.end_time - 1)
    return true if b.end_time.between?(a.start_time + 1, a.end_time)
    false
  end

  # return true if the class location is identical
  def self.instance_location_overlap?(a, b)
    if a.instructable.location_nontrack? and b.instructable.location_nontrack?
      return a.instructable.camp_name == b.instructable.camp_name
    elsif !a.instructable.location_nontrack? and !b.instructable.location_nontrack?
      return false if a.location.blank? or b.location.blank?
      return a.location == b.location
    end
    false
  end

  # return true only if user_id fields are equal
  def self.instance_instructor_overlap?(a, b)
    (!a.instructable.user or !IGNORED_INSTRUCTORS.include?(a.instructable.user.sca_name)) and a.instructable.user_id == b.instructable.user_id
  end

  # return true only if the topic (topic) is equal
  def self.instance_topic_overlap?(a, b)
    return false
    a.instructable.topic == b.instructable.topic
  end

  #
  # Put all of the sub-overlap checks together.
  #
  def self.instance_overlap?(a, b)
    return [] unless instance_time_overlap?(a, b)
    ret = []
    ret << :location if instance_location_overlap?(a, b)
    ret << :instructor if instance_instructor_overlap?(a, b)
    ret << :topic if instance_topic_overlap?(a, b)
    ret
  end
end
