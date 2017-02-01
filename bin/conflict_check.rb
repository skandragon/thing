
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

@conflicts = ConflictCheck.conflicts
if @conflicts.is_a?String
  puts @conflicts
  exit
end

def show_instance(instance)
  puts "     Class: #{instance.instructable.name}"
  puts "Instructor: #{instance.instructable.user.instructor_profile.titled_sca_name}"
  puts "  Instance: #{instance.formatted_location_and_time}"
  puts "     Track: #{instance.instructable.track}"
end

@conflicts.each { |conflict|
  type, instances = conflict
  puts "  Conflict: #{type.join(', ')}"
  show_instance(instances[0])
  puts ' -- with --'
  show_instance(instances[1])
  puts
}

puts "Summary: #{help.pluralize @conflicts.size, 'conflict'}."
