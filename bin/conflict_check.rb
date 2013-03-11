
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
  exit
elsif instances.size == 1
  puts "Only one instance, so no conflicts."
  exit
end

@conflicts = []

while instances.size > 0
  instance = instances.pop
  next if instances.size == 0
  for other in instances
    conflicts = ConflictCheck::Instance.overlap?(instance, other)
    if conflicts.size > 0
      @conflicts << [conflicts, [instance, other]]
    end
  end
end

def show_instance(instance)
  puts "     Class: #{instance.instructable.name}"
  puts "Instructor: #{instance.instructable.user.instructor_profile.titled_sca_name}"
  puts "  Instance: #{instance.formatted_location_and_time}"
  puts "     Track: #{instance.instructable.track}"
end

for conflict in @conflicts
  type, instances = conflict
  puts "  Conflict: #{type.join(', ')}"
  show_instance(instances[0])
  puts " -- with --"
  show_instance(instances[1])
  puts
end
  
puts "Summary: #{help.pluralize @conflicts.size, 'conflict'}."
