class InstructablesController < ApplicationController
  before_filter :authorize, only: [ :edit, :update, :destroy ]
  before_filter :authorize_user

  def index
    @instructables = @target_user.instructables.order(:name).paginate(:page => params[:page], per_page: 10)
  end

  def new
    @instructable = Instructable.new
    render action: :edit
  end

  def create
    @instructable = @target_user.instructables.build(params['instructable'])
    if @instructable.save
      redirect_to user_instructables_path(@target_user), info: "Class created."
      return
    else
      render action: :edit
    end
  end

  def edit
  end

  def update
    if @instructable.update_attributes(params[:instructable])
      redirect_to user_instructables_path(@target_user), notice: "Class updated."
    else
      render action: :edit
    end
  end

  def destroy
    if @instructable
      @instructable.destroy
    end
    redirect_to user_instructables_path(@target_user), info: "Class deleted."
  end

  private

  def current_resource
    @instructable ||= Instructable.find(params[:id])
  end

end
