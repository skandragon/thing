class Admin::TracksController < ApplicationController
  def index
    @scheduled = Instructable.group(:track).where(:scheduled => true).count
    @unscheduled = Instructable.group(:track).where(:scheduled => false).count
    @totals = Instructable.group(:track).count

    @percent_completed = {}
    for track in Instructable::TRACKS.keys
      total = @totals[track]
      if total.to_f > 0
        scheduled = @scheduled[track] || 0
        @percent_completed[track] = (scheduled.to_f / total) * 100
      end
    end
  end
end
