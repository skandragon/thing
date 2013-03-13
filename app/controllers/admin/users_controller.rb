class Admin::UsersController < ApplicationController
  def index
    @users = User.order(:mundane_name, :email).paginate(page: params[:page], per_page: 10)
  end

  def edit
  end

  def update
    if current_resource.update_attributes(user_params)
      redirect_to admin_users_path, notice: "User updated."
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
