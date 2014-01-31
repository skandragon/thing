class Admin::UsersController < ApplicationController
  def index
    @search = params[:search]
    @role = params[:role]
    if params[:commit] == 'Clear'
      @search = nil
      @role = nil
    end

    @users = User.order(:mundane_name, :email)

    case @role
    when 'Admin'
      @users = @users.where(admin: true)
    when 'Coordinator'
      @users = @users.where("tracks <> '{}'")
    when 'Instructor'
      @users = @users.where(instructor: true)
    when 'PU Staff'
      @users = @users.where(pu_staff: true)
    when 'Proofreader'
      @users = @users.where(proofreader: true)
    end

    if @search.present?
      @users = @users.where('mundane_name ILIKE ? OR sca_name ILIKE ? OR email ILIKE ?',
                            "%#{@search.strip}%", "%#{@search.strip}%", "%#{@search.strip}%")
    end

    @users = @users.paginate(page: params[:page], per_page: 10)
  end

  def edit
  end

  def update
    changelog = Changelog.build_changes('update', current_resource, current_user)
    if current_resource.update_attributes(user_params)
      changelog.save # failure is an option...
      redirect_to admin_users_path, notice: 'User updated.'
    else
      render action: :edit
    end
  end

  private

  def current_resource
    if params[:id].present?
      @user ||= User.find(params[:id])
    else
      nil
    end
  end

  def user_params
    params.require(:user).permit!
  end
end
