class InstructablesController < ApplicationController
  before_filter :authorize, only: [ :edit, :update, :destroy ]
  before_filter :authorize_user

  def index
    @instructables = @target_user.instructables.order(:name).paginate(:page => params[:page], per_page: 10)
    session[:instructable_back] = request.fullpath
  end

  def new
    @instructable = Instructable.new
    render action: :edit
  end

  def create
    @instructable = @target_user.instructables.build(permitted_params)
    if @instructable.save
      redirect_to user_instructables_path(@target_user), notice: "Class created."
      return
    else
      render action: :edit
    end
  end

  def edit
  end

  def update
    if @instructable.update_attributes(permitted_params)
      redirect_to session[:coordinator_instructable_back] || user_instructables_path(@target_user), notice: "Class updated."
    else
      render action: :edit
    end
  end

  def destroy
    if @instructable
      @instructable.destroy
    end
    redirect_to user_instructables_path(@target_user), notice: "Class deleted."
  end

  private

  def current_resource
    if params[:id].present?
      @instructable ||= Instructable.find(params[:id])
    end
    @instructable
  end

  def permitted_params
    allowed = [
      :description_web, :description_book, :name, :duration, :handout_limit,
      :handout_fee, :material_limit, :material_fee, :fee_itemization,
      :location_camp, :camp_name, :camp_address, :camp_reason, :adult_only,
      :adult_reason, :requested_days, :requested_times, :repeat_count,
      :scheduling_additional, :special_needs, :special_needs_description,
      :heat_source, :heat_source_description, :additional_instructors_expanded,
      :culture, :topic, :subtopic,
    ]
    if params[:action] == "update"
      if coordinator_for?(current_resource.tract)
        allowed += [ :approved, :start_time ]
      end
      if admin?
        allowed += [ :tract ]
      end
    end
    params.require(:instructable).permit(*allowed)
  end
end
