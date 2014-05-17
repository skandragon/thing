class InstructablesController < ApplicationController
  before_filter :authorize, only: [ :edit, :update, :destroy ]
  before_filter :authorize_user

  def index
    @instructables = @target_user.instructables.order(:name).paginate(:page => params[:page], per_page: 10)
    session[:instructable_back] = request.fullpath

    @previous_year_classes = @target_user.instructables.unscoped.where(user_id: @target_user.id).where("year < #{Time.now.year}").order(:year, :name)
  end

  def new
    if params[:clone_from]
      clone_id = params[:clone_from].to_i
      clone_from = Instructable.unscoped.where(user_id: @current_user.id, id: clone_id)
      @instructable = clone_from.first
      if @instructable
        @instructable = @instructable.dup  # clone all fields, make new record
        @instructable.requested_days = []
        flash[:alert] = "Most data has been copied from your previous year's class.  Please check each item carefully and update it as necessary.  Requested class dates are not copied, for the obvious reason."
      end
    end
    @instructable ||= Instructable.new
    render action: :edit
  end

  def create
    @instructable = @target_user.instructables.build(permitted_params)
    changelog = Changelog.build_changes('create', @instructable, current_user)
    if @instructable.save
      changelog.target_id = @instructable.id
      changelog.save # failure is an option...
      send_email_on_create
      redirect_to user_instructables_path(@target_user), notice: 'Class created.'
    else
      render action: :edit
    end
  end

  def edit
    @instances = @instructable.instances
    need = @instructable.repeat_count - @instructable.instances.count
    need.times do
      @instances.build
    end
  end

  def update
    preflight = Changelog.build_attributes(@instructable)
    @instructable.assign_attributes(permitted_params)
    @instructable.adjust_instances
    changelog = Changelog.build_changes('update', @instructable, current_user)
    if @instructable.save
      @instructable.cleanup_unneeded_instances
      changelog.original = preflight
      changelog.validate_and_save # failure is an option...
      redirect_to session[:instructable_back] || user_instructables_path(@target_user), notice: 'Class updated.'
    else
      render action: :edit
    end
  end

  def destroy
    if @instructable
      changelog = Changelog.build_destroy(@instructable, current_user)
      changelog.save # failure is an option...
      @instructable.destroy
    end
    redirect_to user_instructables_path(@target_user), notice: 'Class deleted.'
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
    if params[:action] == 'update'
      if coordinator_for?(current_resource.track)
        if admin?
          allowed += [ :schedule, :approved, :instances_attributes => [ :id, :start_time, :location, :override_location ] ]
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

    begin
      InstructablesMailer.on_create(@instructable, user_address).deliver
    rescue Exception => e
      flash[:error] = "Email could not be delivered to your account's email address, #{@instructable.user.email}.  However, the requested class was successfully added.  Please update your profile."
    end

    admin_addresses.each do |address|
      begin
        InstructablesMailer.on_create(@instructable, address).deliver
      rescue Exception => e
        flash[:error] = 'Email could not be sent to one or more track coordinators.  However, your class was added and will appear on their pending class lists.'
      end
    end
  end
end
