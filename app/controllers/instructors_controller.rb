class InstructorsController < ApplicationController
  def index
    @order = params[:order]

    instructor_ids = Instructable.pluck(:user_id).uniq
    @instructors = User.where(id: instructor_ids)

    if @order == 'kingdom'
      @instructors = @instructors.order('kingdom, lower(sca_name)')
    else
      @instructors = @instructors.order('lower(sca_name)')
    end
  end
end
