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
      send_email_on_create
      redirect_to user_instructables_path(@target_user), notice: "Class created."
      return
    else
      render action: :edit
    end
  end

  def edit
    @instances = @instructable.instances
    need = @instructable.repeat_count - @instructable.instances.count
    if need > 0
      need.times do
        i = @instances.build
      end
    end
  end

  def update
    if @instructable.update_attributes(permitted_params)
      redirect_to session[:instructable_back] || user_instructables_path(@target_user), notice: "Class updated."
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
      :location_type, :camp_name, :camp_address, :camp_reason, :adult_only,
      :adult_reason, :repeat_count,
      :scheduling_additional, :special_needs_description,
      :heat_source, :heat_source_description, :additional_instructors_expanded,
      :culture, :topic, :subtopic,
    ]
    allowed += [{:requested_days => [], :requested_times => [], :special_needs => []}]
    if params[:action] == "update"
      if coordinator_for?(current_resource.track)
        if admin?
          allowed += [ :approved, :instances_attributes => [ :id, :start_time, :location, :override_location ] ]
        else
          allowed += [ :approved, :instances_attributes => [ :id, :start_time, :location ] ]
        end
      end
      if admin?
        allowed += [ :track ]
      end
    end
    params.require(:instructable).permit(*allowed)
  end

  def send_email_on_create
    user_address = @instructable.user.email
    admin_addresses = User.where(admin: true).pluck(:email)
    admin_addresses -= [user_address]

    InstructablesMailer.on_create(@instructable, user_address).deliver
    for address in admin_addresses
      InstructablesMailer.on_create(@instructable, address).deliver
    end
  end
end
