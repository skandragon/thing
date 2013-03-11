
def help
  Helper.instance
end

class Helper
  include Singleton
  include ActionView::Helpers::TextHelper
end

#
# Walk through the Instances which have a time value set, and compare
# each one to all of the other following ones.
#
# This is a very, very brute force implementation, probably not suitable
# for real-time in-UI use.
#

instances = Instance.where("start_time IS NOT NULL").order(:start_time)

if instances.size == 0
  puts "No instances of any classes."
  exit 0
elsif instances.size == 1
  puts "Only one instance, so no conflicts."
  exit 0
end

@conflicts = 0

while instances.size > 0
  instance = instances.pop
  next if instances.size == 0
  for other in instances
    conflicts = ConflictCheck::Instance.overlap?(instance, other)
    if conflicts.size > 0
      puts "  Conflict: #{conflicts.join(', ')}"
      puts "     Class: #{instance.instructable.name}"
      puts "Instructor: #{instance.instructable.user.instructor_profile.titled_sca_name}"
      puts "  Instance: #{instance.formatted_location_and_time}"
      puts " -- with --"
      puts "     Class: #{other.instructable.name}"
      puts "Instructor: #{other.instructable.user.instructor_profile.titled_sca_name}"
      puts "  Instance: #{other.formatted_location_and_time}"
      puts
      @conflicts += 1
    end
  end
end

puts "Summary: #{help.pluralize @conflicts, 'conflict'}."
exit 1 if @conflicts > 0

exit 0