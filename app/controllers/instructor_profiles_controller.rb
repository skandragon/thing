class InstructorProfilesController < ApplicationController
  def new
    @user.add_missing_contacts
    render action: :edit
  end

  def edit
    @user.add_missing_contacts
  end

  def update
    if @user.instructor?
      notice = 'Instructor profile updated.'
    else
      notice = 'Instructor profile created.'
    end
    @user.instructor = true
    if @user.update_attributes(permitted_params)
      redirect_to root_path, notice: notice
    else
      render action: :edit
    end
  end

  private

  def permitted_params
    params.require(:user).permit(
      :mundane_name, :phone_number, :sca_name, :sca_title, :phone_number_onsite,
      :kingdom, :no_contact,
      { :instructor_profile_contacts_attributes => [ :address, :protocol, :id ] },
      :available_days => []
     )
  end

  def current_resource
    @user ||= current_user
  end
end
