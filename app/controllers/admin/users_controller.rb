class Admin::UsersController < ApplicationController
  def index
    @search = params[:search]

    if params[:commit] == "Clear"
      @search = nil
    end

    @users = User.order(:mundane_name, :email)

    if @search.present?
      @users = @users.where('mundane_name ILIKE ? OR sca_name ILIKE ? OR email ILIKE ?',
                            "%#{@search.strip}%", "%#{@search.strip}%", "%#{@search.strip}%")
    end

    @users = @users.paginate(page: params[:page], per_page: 10)
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
