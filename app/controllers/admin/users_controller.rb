class Admin::UsersController < ApplicationController
  def index
    @search = params[:search]
    @role = params[:role]
    if params[:commit] == 'Clear'
      @search = nil
      @role = nil
    end

    @users = User.order(:mundane_name, :email)
    @users = @users.by_role(@role) if @role
    @users = @users.search_name(@search) if @search.present?
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

  def send_password_reset_email
    user = User.find(params[:user_id])
    Rails.logger.info "Changing password for #{user.email}"
    user.send_reset_password_instructions
    redirect_to admin_users_path, notice: "Password reset instructions sent to #{user.email}"
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
