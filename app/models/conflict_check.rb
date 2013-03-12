
class ConflictCheck ; end

require 'conflict_check/instance'

class ConflictCheck
  def self.conflicts
    instances = ::Instance.where("start_time IS NOT NULL").order(:start_time)
    if instances.size == 0
      return 'No instances found'
    elsif instances.size == 1
      return 'Only one instance found'
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
    
    @conflicts
  end
end

