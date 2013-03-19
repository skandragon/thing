class Admin::TracksController < ApplicationController
  def index
    @scheduled = Instructable.group(:track).where(:scheduled => true).count
    @unscheduled = Instructable.group(:track).where(:scheduled => false).count
    @totals = Instructable.group(:track).count
    @topic_counts = Instructable.group(:topic, :subtopic).count
    @topic_hours = Instructable.group(:topic, :subtopic).sum("duration * repeat_count")
    @instructable_count = Instructable.count
    @instructable_session_count = Instructable.sum(:repeat_count)
    @instructor_count = Instructable.pluck(:user_id).uniq.size
    @total_hours = Instructable.sum("duration * repeat_count")

    @percent_completed = {}
    Instructable::TRACKS.keys.each do |track|
      total = @totals[track]
      if total.to_f > 0
        scheduled = @scheduled[track] || 0
        @percent_completed[track] = (scheduled.to_f / total) * 100
      end
    end
  end
end
